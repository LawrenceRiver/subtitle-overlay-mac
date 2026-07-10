import AppKit
import OverlayCore

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var overlayWindow: OverlayWindow?
    private let defaults = UserDefaults.standard

    private enum Keys {
        static let x = "overlay.frame.x"
        static let y = "overlay.frame.y"
        static let width = "overlay.frame.width"
        static let height = "overlay.frame.height"
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        let screen = screenForSavedFrame() ?? NSScreen.main?.visibleFrame ?? CGRect(x: 0, y: 0, width: 1440, height: 900)
        let frame = restoredFrame(in: screen) ?? OverlayGeometry.initialFrame(in: screen)
        let window = OverlayWindow(frame: frame) { [weak self] in
            self?.closeOverlay()
        }

        overlayWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        window.makeFirstResponder(window.contentView)
    }

    func applicationWillTerminate(_ notification: Notification) {
        saveCurrentFrame()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    private func closeOverlay() {
        saveCurrentFrame()
        NSApp.terminate(nil)
    }

    private func restoredFrame(in screen: CGRect) -> CGRect? {
        guard
            let x = defaults.object(forKey: Keys.x) as? Double,
            let y = defaults.object(forKey: Keys.y) as? Double,
            let width = defaults.object(forKey: Keys.width) as? Double,
            let height = defaults.object(forKey: Keys.height) as? Double,
            width.isFinite,
            height.isFinite,
            width > 0,
            height > 0
        else {
            return nil
        }

        let savedFrame = CGRect(x: x, y: y, width: width, height: height)
        return OverlayGeometry.clampedFrame(savedFrame, to: screen)
    }

    private func screenForSavedFrame() -> CGRect? {
        guard
            let x = defaults.object(forKey: Keys.x) as? Double,
            let y = defaults.object(forKey: Keys.y) as? Double,
            let width = defaults.object(forKey: Keys.width) as? Double,
            let height = defaults.object(forKey: Keys.height) as? Double
        else {
            return nil
        }

        let savedFrame = CGRect(x: x, y: y, width: width, height: height)
        return NSScreen.screens.first(where: { $0.frame.intersects(savedFrame) })?.visibleFrame
    }

    private func saveCurrentFrame() {
        guard let frame = overlayWindow?.frame else { return }
        defaults.set(frame.origin.x, forKey: Keys.x)
        defaults.set(frame.origin.y, forKey: Keys.y)
        defaults.set(frame.size.width, forKey: Keys.width)
        defaults.set(frame.size.height, forKey: Keys.height)
    }
}
