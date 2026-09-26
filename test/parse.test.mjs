// Tests the parsing core embedded in index.html against the real layout.
// Run: node test/parse.test.mjs
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import vm from 'node:vm';
import assert from 'node:assert/strict';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const html = readFileSync(join(root, 'index.html'), 'utf8');
const core = html.split('// @core-start')[1].split('// @core-end')[0];
const sandbox = { module: { exports: {} } };
vm.runInNewContext(core, sandbox);
const VL = sandbox.module.exports;
const vil = JSON.parse(readFileSync(join(root, 'layouts', 'miryoku-11.vil'), 'utf8'));

let passed = 0;
const t = (name, fn) => { fn(); passed++; console.log('ok  ' + name); };
const ctx = { os: 'mac', vil, layerName: n => ['Base', 'Nav', 'Mouse', 'Media', 'Num', 'Layer 5'][n] };
const d = c => VL.describe(c, ctx);

t('plain keys', () => {
  assert.equal(d('KC_Q').tap, 'Q');
  assert.equal(d('KC_SCOLON').tap, ';');
  assert.equal(d('KC_PGDOWN').tap, 'Pg Dn');
  assert.equal(d('KC_NO').kind, 'none');
  assert.equal(d('KC_TRNS').kind, 'trans');
  assert.equal(d(-1).kind, 'absent');
});
t('mod-tap reads as key / mod', () => {
  const k = d('LSFT_T(KC_A)');
  assert.equal(k.tap, 'A'); assert.equal(k.hold, 'Shift');
  assert.equal(d('RGUI_T(KC_N)').hold, 'Cmd');
  assert.equal(d('MT(MOD_LCTL|MOD_LSFT,KC_X)').hold, 'Ctrl+Shift');
});
t('shortcuts get friendly names', () => {
  assert.equal(d('LGUI(KC_Z)').tap, 'Undo');
  assert.equal(d('SGUI(KC_Z)').tap, 'Redo');
  assert.equal(d('SGUI(KC_RBRACKET)').tap, 'Next tab');
  assert.equal(d('LCG(KC_Q)').tap, 'Lock');
  assert.equal(d('LCTL(KC_BRID)').tap, '⌃ Bright -');
});
t('layer keys', () => {
  assert.equal(d('TO(0)').tap, 'To Base');
  assert.equal(d('MO(1)').holdLayer, 1);
  const lt = d('LT(4,KC_BSPACE)');
  assert.equal(lt.tap, 'Bksp'); assert.equal(lt.hold, 'Num');
  assert.equal(d('LT2(KC_TAB)').hold, 'Mouse');
});
t('one-shot mods', () => {
  const o = d('OSM(MOD_LSFT)');
  assert.equal(o.tap, 'Shift'); assert.equal(o.sub, 'one-shot');
});
t('tap dance expands from the file', () => {
  const td3 = d('TD(3)');
  assert.equal(td3.tap, 'Space'); assert.equal(td3.hold, 'Nav'); assert.equal(td3.holdLayer, 1);
  assert.ok(td3.extras.some(e => e.label === 'tap+hold' && e.text === 'Toggle Nav'));
  const td1 = d('TD(1)');
  assert.equal(td1.tap, 'D'); assert.equal(td1.hold, 'F11');
  const td7 = d('TD(7)');
  assert.equal(td7.tap, 'Z'); assert.ok(td7.extras.some(e => e.label === '2x'));
});
t('macros are described', () => {
  assert.equal(VL.macroText(0, ctx).short, 'Shift x2');
  assert.equal(VL.macroText(1, ctx).short, '⌃ Space');
  assert.equal(VL.macroText(4, ctx).short, 'Snip area');
  assert.equal(d('M3').tap, '⌥⌘C');
});
t('whole file analysis', () => {
  const m = VL.analyse(vil, { os: 'mac' });
  assert.deepEqual(Array.from(m.layers.map(l => l.name)), ['Base', 'Nav', 'Mouse', 'Media', 'Num', 'Layer 5']);
  assert.equal(m.layers[5].empty, true);
  assert.equal(m.geo.split, true);
  // 3x6 per side + 3 thumbs = 42 keys; unused inner extra column is hidden.
  assert.equal(m.geo.keys.length, 42);
  // Each non-empty layer can be reached from the base layer by holding a key.
  for (const i of [1, 2, 3, 4]) assert.ok(m.layers[i].reach.some(r => r.from === 0 && r.how === 'hold'), 'reach layer ' + i);
  assert.equal(VL.reachText(m.layers[1], m), 'hold Space');
  // Left thumbs, outer to inner: Esc, Space, Tab. Right thumbs mirrored.
  const left = m.geo.keys.map((k, i) => ({ k, i })).filter(x => x.k.side === 'left' && x.k.row === 'thumb row').sort((a, b) => a.k.x - b.k.x);
  assert.deepEqual(Array.from(left.map(x => m.cells[0][x.i].tap)), ['Esc', 'Space', 'Tab']);
  const right = m.geo.keys.map((k, i) => ({ k, i })).filter(x => x.k.side === 'right' && x.k.row === 'thumb row').sort((a, b) => a.k.x - b.k.x);
  assert.equal(m.cells[0][right[0].i].tap, 'Enter');
  assert.equal(m.cells[0][right[1].i].hold, 'Num');
  // Right top row reads J L U Y ' left to right.
  const top = m.geo.keys.map((k, i) => ({ k, i })).filter(x => x.k.side === 'right' && x.k.row === 'top row').sort((a, b) => a.k.x - b.k.x);
  assert.deepEqual(Array.from(top.map(x => m.cells[0][x.i].tap).filter(Boolean).slice(0, 5)), ['J', 'L', 'U', 'Y', "'"]);
});
t('keys are square, thumbs sit close under the block in a gentle row', () => {
  const m = VL.analyse(vil, { os: 'mac' });
  for (const k of m.geo.keys) { assert.equal(k.w, 1); assert.equal(k.h, 1); }
  const thumbs = side => m.geo.keys.filter(k => k.side === side && k.row === 'thumb row').sort((a, b) => a.x - b.x);
  // (+ 0 turns -0 into 0; Array.from brings the array out of the test sandbox's realm.)
  const rots = side => Array.from(thumbs(side).map(k => k.rot + 0));
  assert.deepEqual(rots('left'), [0, 4, 8]);
  assert.deepEqual(rots('right'), [-8, -4, 0]);
  // Near-straight: the three thumbs drop by no more than a fifth of a key from outer to inner.
  const ys = thumbs('left').map(k => k.y);
  assert.ok(ys[2] - ys[0] <= 0.2 + 1e-9);
  // Six columns per half, the outer one included, even where nothing is mapped on it.
  const cols = side => new Set(m.geo.keys.filter(k => k.side === side && k.row !== 'thumb row').map(k => k.c)).size;
  assert.equal(cols('left'), 6); assert.equal(cols('right'), 6);
  // The whole board sits inside its stated size, turned thumbs included, and no two keys overlap.
  const bs = m.geo.keys.map(k => VL.bounds(k));
  for (const b of bs) assert.ok(b.x0 >= -0.001 && b.x1 <= m.geo.width + 0.001 && b.y1 <= m.geo.height + 0.001);
  for (let i = 0; i < bs.length; i++) for (let j = i + 1; j < bs.length; j++) {
    const a = bs[i], b = bs[j];
    // Box around each key (a turned key's box is a little bigger than the key), so allow a sliver.
    const overlap = Math.min(a.x1, b.x1) - Math.max(a.x0, b.x0) > 0.06 && Math.min(a.y1, b.y1) - Math.max(a.y0, b.y0) > 0.06;
    assert.ok(!overlap, 'keys ' + i + ' and ' + j + ' overlap');
  }
  // Thumbs tucked in: the inner thumb ends less than a key beyond the inner column.
  const leftBlock = Math.max(...m.geo.keys.filter(k => k.side === 'left' && k.row !== 'thumb row').map(k => VL.bounds(k).x1));
  const leftThumb = Math.max(...thumbs('left').map(k => VL.bounds(k).x1));
  assert.ok(leftThumb - leftBlock < 0.5, 'thumb reach ' + (leftThumb - leftBlock));
  // Halves close together: the space between the two main blocks is under 1.3 keys (it was 2.5).
  const rightBlock = Math.min(...m.geo.keys.filter(k => k.side === 'right' && k.row !== 'thumb row').map(k => VL.bounds(k).x0));
  assert.ok(rightBlock - leftBlock < 1.3, 'middle gap ' + (rightBlock - leftBlock));
  // Wide and short, like the keyboard: about 3 to 1, and narrower than the old fan (14.5 keys).
  assert.ok(m.geo.width / m.geo.height > 2.8 && m.geo.width / m.geo.height < 3.3);
  assert.ok(m.geo.width < 13.3, 'width ' + m.geo.width);
});
t('every text colour reaches WCAG AA (4.5:1) on every key face', () => {
  assert.equal(Math.round(VL.contrast('#000000', '#ffffff')), 21);
  for (const [name, th] of Object.entries(VL.THEMES)) {
    for (const face of [th.key, th.keyHover, th.keyPressed]) {
      for (const c of [th.text, th.muted, th.faint, ...th.palette]) {
        const r = VL.contrast(c, face);
        assert.ok(r >= 4.5, name + ': ' + c + ' on ' + face + ' is ' + r.toFixed(2));
      }
    }
  }
});
t('layer colours stay distinct from each other', () => {
  // The first five (Base and the four layers in use) must not be confusable: each pair differs
  // clearly in hue or lightness.
  for (const th of Object.values(VL.THEMES)) {
    const rgb = h => [1, 3, 5].map(i => parseInt(h.slice(i, i + 2), 16));
    const p = th.palette.slice(0, 5).map(rgb);
    for (let i = 0; i < p.length; i++) for (let j = i + 1; j < p.length; j++) {
      const d = Math.hypot(...p[i].map((v, k) => v - p[j][k]));
      assert.ok(d > 90, 'colours ' + i + ' and ' + j + ' too close: ' + d.toFixed(0));
    }
  }
});
t('board size: side by side when that gives bigger keys, stacked on a phone', () => {
  const g = VL.analyse(vil, { os: 'mac' }).geo;
  const small = VL.planSize(g, 734, 350);
  assert.equal(small.stacked, false);
  assert.ok(small.u >= 53, '750x400 key ' + small.u);
  assert.equal(VL.planSize(g, 359, 700).stacked, true);
  assert.ok(VL.planSize(g, 359, 700).u >= 50);
  // Never below the legible floor: a tiny window scrolls rather than shrinking keys past it.
  assert.ok(VL.planSize(g, 300, 200).u >= VL.MIN_U);
  // Height to spare lets keys grow a little taller than wide, to fit their words; never more than 1.35.
  assert.ok(small.maxTall > 1.2 && small.maxTall <= 1.35);
  assert.ok(VL.planSize(g, 1416, 300).maxTall < 1.05);
});
t('pc labels', () => {
  const pc = { ...ctx, os: 'pc' };
  assert.equal(VL.describe('LGUI_T(KC_T)', pc).hold, 'Win');
  assert.equal(VL.describe('LCTL(KC_C)', pc).tap, 'Copy');
});
t('generic keyboard falls back to a grid', () => {
  const m = VL.analyse({ layout: [[['KC_A', 'KC_B'], ['KC_C', 'KC_D']]] });
  assert.equal(m.geo.split, false); assert.equal(m.geo.keys.length, 4);
});
t('your own names replace labels, including inside tap dances', () => {
  const noted = { ...ctx, notes: { M3: 'Alfred clipboard', KC_F11: 'Show desktop' } };
  const td2 = VL.describe('TD(2)', noted);
  assert.equal(td2.tap, 'C'); assert.equal(td2.hold, 'Alfred clipboard');
  assert.deepEqual(Array.from(td2.parts.map(p => p.label + ' ' + p.code)), ['Tap KC_C', 'Hold M3', 'Tap then hold M4']);
  assert.equal(VL.describe('TD(1)', noted).hold, 'Show desktop');
  const m3 = VL.describe('M3', noted);
  assert.equal(m3.tap, 'Alfred clipboard'); assert.equal(m3.sub, '⌥⌘C'); assert.match(m3.full, /Macro 3/);
  assert.equal(VL.describe('KC_Q', noted).parts[0].code, 'KC_Q');
  const m = VL.analyse(vil, { os: 'mac', notes: { M3: 'Alfred clipboard' } });
  assert.ok(m.cells[0].some(c => c.hold === 'Alfred clipboard'));
});
t('hovering a tap dance, tap or hold, tells its whole story', () => {
  const noted = { ...ctx, notes: { M3: 'Alfred clipboard', M4: 'Screenshot' } };
  const full = VL.describe('TD(2)', noted).full;
  assert.match(full, /Tap: C/);
  assert.match(full, /Hold: Alfred clipboard/);
  assert.match(full, /Tap then hold: Screenshot/);
  // The hold legend's tooltip is that same full line, not just "Hold: ..."
  assert.match(html, /c: 'hold', text: base\.hold, col: holdCol, title: baseTitle \|\|/);
});
t('rejects non-vil JSON', () => {
  assert.throws(() => VL.analyse({ foo: 1 }), /no "layout"/);
});
console.log(`\n${passed} tests passed`);
