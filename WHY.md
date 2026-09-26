# Why this exists

## The problem

Learning a layered layout on a Corne means constantly forgetting what is on each layer. Vial shows one layer at a time, with tap dances as `TD(3)` and mod-taps as raw codes, so answering "where is Page Down?" means opening the configurator, clicking through layers and decoding keycodes. The Vial desktop app now needs Rosetta on Apple silicon, and the web version is a browser tab and a device prompt away. Every lookup costs more than the keystroke it is for, which is the wrong way round while a layout is still being learned.

## Who it helps

First, Dileepa, learning a Miryoku-derived Colemak-DH layout on a Corne. Then anyone using Vial on a split keyboard who wants the picture Miryoku's own reference gives, generated from their own layout rather than drawn by hand.

## What good looks like

Opening it is one action. It shows every layer on one screen, in plain words and colours, dark and high contrast by default. When the layout changes, the map changes by loading the new file, never by redrawing anything.

## The test

**Can you find what a key does on any layer in under 5 seconds**, from the map being open? Two ways to check:

1. **Find a function:** "where is Page Down?" Look for it in the Nav colour on the overview. It passes if found in under 5 seconds.
2. **Read a key:** "what does the key under my right ring finger do on the Media layer?" Point at the key; the panel says, in words. It passes if answered in under 5 seconds.

If either regularly takes longer, the labels or the layout of the map are wrong, and that is the thing to fix before adding features.
