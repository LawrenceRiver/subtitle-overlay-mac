import AppKit
import OverlayCore

final class OverlayWindow: NSWindow {
    private let closeHandler: () -> Void

    init(frame: CGRect, onClose: @escaping () -> Void) {
        closeHandler = onClose
        super.init(
            contentRect: frame,
            styleMask: [.borderless, .resizable],
            backing: .buffered,
            defer: false
        )

        isOpaque = true
        backgroundColor = .black
        hasShadow = false
        level = .screenSaver
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        isMovableByWindowBackground = true
        minSize = OverlayGeometry.defaultMinimumSize
        isReleasedWhenClosed = false
        contentView = OverlayView(onClose: closeHandler)
    }

    override var canBecomeKey: Bool { true }

    override var canBecomeMain: Bool { true }
}
