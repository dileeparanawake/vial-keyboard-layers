// Vial Keyboard Layers: a small Mac app that shows the repo's index.html in its own window,
// with its own Dock icon. Build it with `sh hotkey/mac-app/build.sh`.
//
// The page's path is written into Info.plist (VLIndexPath) at build time, so the app always shows
// the current index.html: a `git pull` updates it without a rebuild.
// Launch arguments: `--layer N` (or `--layer all`) opens that layer (the page reads ?layer=).

import AppKit
import WebKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate,
                         WKNavigationDelegate, WKUIDelegate, WKDownloadDelegate {
    private var window: NSWindow!
    private var webView: WKWebView!
    private var indexURL: URL?
    private var termSource: DispatchSourceSignal?

    // MARK: Launch

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSWindow.allowsAutomaticWindowTabbing = false  // one window: no Show Tab Bar in the menus
        NSApp.mainMenu = makeMainMenu()
        quitGracefullyOnSIGTERM()

        let config = WKWebViewConfiguration()
        // Persistent storage, so the page's localStorage (your layout and key names) survives a relaunch.
        config.websiteDataStore = .default()
        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = false

        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1400, height: 800),
                          styleMask: [.titled, .closable, .miniaturizable, .resizable],
                          backing: .buffered, defer: false)
        window.title = "Vial Keyboard Layers"
        window.contentView = webView
        window.delegate = self
        window.isRestorable = false
        window.minSize = NSSize(width: 480, height: 320)
        window.setFrame(firstLaunchFrame(), display: false)
        // Restores the saved size and position if there is one, and saves every change from now on.
        window.setFrameAutosaveName("VialKeyboardLayersWindow")
        if !NSScreen.screens.contains(where: { $0.visibleFrame.intersects(window.frame) }) {
            window.setFrame(firstLaunchFrame(), display: false)  // saved on a screen that is gone
        }

        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(webView)  // so digits, Esc, arrows and letters reach the page
        if #available(macOS 14.0, *) { NSApp.activate() } else { NSApp.activate(ignoringOtherApps: true) }

        loadPage()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }

    /// About 1400×800, never more than 95% of the main screen's usable area, centred.
    private func firstLaunchFrame() -> NSRect {
        let visible = (NSScreen.main ?? NSScreen.screens.first)?.visibleFrame
            ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let w = min(1400, visible.width * 0.95)
        let h = min(800, visible.height * 0.95)
        return NSRect(x: visible.midX - w / 2, y: visible.midY - h / 2, width: w, height: h).integral
    }

    /// `pkill` (used by toggle.sh) sends SIGTERM. Quit the normal way, so the window frame and the
    /// page's storage are saved, instead of dying on the spot.
    private func quitGracefullyOnSIGTERM() {
        signal(SIGTERM, SIG_IGN)
        let source = DispatchSource.makeSignalSource(signal: SIGTERM, queue: .main)
        source.setEventHandler { NSApp.terminate(nil) }
        source.resume()
        termSource = source
    }

    // MARK: Page

    private func loadPage() {
        let path = Bundle.main.object(forInfoDictionaryKey: "VLIndexPath") as? String ?? ""
        guard !path.isEmpty, FileManager.default.fileExists(atPath: path) else {
            showMessage("Can't find index.html",
                        "Looked for: \(path.isEmpty ? "(no path set)" : path)<br>Rebuild the app: <code>sh hotkey/mac-app/build.sh</code>")
            return
        }
        let file = URL(fileURLWithPath: path)
        indexURL = file
        var parts = URLComponents(url: file, resolvingAgainstBaseURL: false)!
        if let layer = layerArgument() { parts.queryItems = [URLQueryItem(name: "layer", value: layer)] }
        // Read access to the whole repo folder, for the icons and files beside index.html.
        webView.loadFileURL(parts.url ?? file, allowingReadAccessTo: file.deletingLastPathComponent())
    }

    private func layerArgument() -> String? {
        let args = CommandLine.arguments
        guard let i = args.firstIndex(of: "--layer"), i + 1 < args.count else { return nil }
        let value = args[i + 1]
        return value == "all" || Int(value) != nil ? value : nil
    }

    private func showMessage(_ title: String, _ body: String) {
        webView.loadHTMLString("""
            <body style="font: 15px -apple-system; padding: 2em; color-scheme: light dark">
            <h2>\(title)</h2><p>\(body)</p></body>
            """, baseURL: nil)
    }

    @objc func reloadPage(_ sender: Any?) { loadPage() }

    // MARK: Links and navigation

    private func isOwnPage(_ url: URL) -> Bool {
        guard url.isFileURL, let index = indexURL else { return false }
        return url.standardizedFileURL.path == index.standardizedFileURL.path
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void) {
        if navigationAction.shouldPerformDownload { decisionHandler(.download); return }
        guard let url = navigationAction.request.url else { decisionHandler(.cancel); return }
        let scheme = url.scheme?.lowercased() ?? ""
        let isMainFrame = navigationAction.targetFrame?.isMainFrame ?? true
        if ["about", "blob", "data"].contains(scheme) || isOwnPage(url) || (!isMainFrame && scheme != "file") {
            decisionHandler(.allow)
        } else if scheme == "file" {
            decisionHandler(.cancel)  // e.g. a file dropped outside the page's drop area: don't replace the map
        } else {
            NSWorkspace.shared.open(url)  // Vial, GitHub, LinkedIn, the website: the default browser
            decisionHandler(.cancel)
        }
    }

    // window.open(): open web links in the default browser, never a second window here.
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url, let scheme = url.scheme?.lowercased(),
           ["http", "https", "mailto"].contains(scheme) {
            NSWorkspace.shared.open(url)
        }
        return nil
    }

    // Keep the page when something goes wrong, instead of a blank window.
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) { loadPage() }

    // MARK: File picker ("Load .vil", notes import)

    func webView(_ webView: WKWebView, runOpenPanelWith parameters: WKOpenPanelParameters,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping @MainActor ([URL]?) -> Void) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = parameters.allowsDirectories
        panel.allowsMultipleSelection = parameters.allowsMultipleSelection
        panel.beginSheetModal(for: window) { response in
            completionHandler(response == .OK ? panel.urls : nil)
        }
    }

    // MARK: Downloads ("Export notes.json")

    func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
        download.delegate = self
    }

    func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
        download.delegate = self
    }

    func download(_ download: WKDownload, decideDestinationUsing response: URLResponse,
                  suggestedFilename: String, completionHandler: @escaping @MainActor (URL?) -> Void) {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = suggestedFilename
        panel.directoryURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        panel.beginSheetModal(for: window) { response in
            guard response == .OK, let url = panel.url else { completionHandler(nil); return }
            // The panel already asked "Replace?". The old file goes to the Bin, as WebKit won't overwrite.
            if FileManager.default.fileExists(atPath: url.path) {
                try? FileManager.default.trashItem(at: url, resultingItemURL: nil)
            }
            completionHandler(url)
        }
    }

    func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
        let alert = NSAlert()
        alert.messageText = "Couldn't save the file"
        alert.informativeText = error.localizedDescription
        alert.beginSheetModal(for: window)
    }

    // MARK: alert() and confirm()

    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping @MainActor () -> Void) {
        let alert = NSAlert()
        alert.messageText = message
        alert.beginSheetModal(for: window) { _ in completionHandler() }
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping @MainActor (Bool) -> Void) {
        let alert = NSAlert()
        alert.messageText = message
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        alert.beginSheetModal(for: window) { completionHandler($0 == .alertFirstButtonReturn) }
    }

    // MARK: Menus

    private func makeMainMenu() -> NSMenu {
        let name = "Vial Keyboard Layers"
        let main = NSMenu()

        let app = NSMenu(title: name)
        app.addItem(withTitle: "About \(name)", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        app.addItem(.separator())
        app.addItem(withTitle: "Hide \(name)", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
        let others = app.addItem(withTitle: "Hide Others", action: #selector(NSApplication.hideOtherApplications(_:)), keyEquivalent: "h")
        others.keyEquivalentModifierMask = [.command, .option]
        app.addItem(withTitle: "Show All", action: #selector(NSApplication.unhideAllApplications(_:)), keyEquivalent: "")
        app.addItem(.separator())
        app.addItem(withTitle: "Quit \(name)", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        add(app, to: main)

        let edit = NSMenu(title: "Edit")
        edit.addItem(withTitle: "Undo", action: Selector(("undo:")), keyEquivalent: "z")
        let redo = edit.addItem(withTitle: "Redo", action: Selector(("redo:")), keyEquivalent: "z")
        redo.keyEquivalentModifierMask = [.command, .shift]
        edit.addItem(.separator())
        edit.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        edit.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        edit.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        edit.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        add(edit, to: main)

        let view = NSMenu(title: "View")
        let reload = view.addItem(withTitle: "Reload", action: #selector(reloadPage(_:)), keyEquivalent: "r")
        reload.target = self
        view.addItem(.separator())
        let full = view.addItem(withTitle: "Enter Full Screen", action: #selector(NSWindow.toggleFullScreen(_:)), keyEquivalent: "f")
        full.keyEquivalentModifierMask = [.command, .control]
        add(view, to: main)

        let win = NSMenu(title: "Window")
        win.addItem(withTitle: "Minimise", action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m")
        win.addItem(withTitle: "Zoom", action: #selector(NSWindow.performZoom(_:)), keyEquivalent: "")
        win.addItem(.separator())
        win.addItem(withTitle: "Close", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
        add(win, to: main)
        NSApp.windowsMenu = win

        return main
    }

    private func add(_ menu: NSMenu, to main: NSMenu) {
        let item = NSMenuItem(title: menu.title, action: nil, keyEquivalent: "")
        item.submenu = menu
        main.addItem(item)
    }
}

MainActor.assumeIsolated {
    let app = NSApplication.shared
    let delegate = AppDelegate()
    app.delegate = delegate
    app.setActivationPolicy(.regular)
    app.run()
}
