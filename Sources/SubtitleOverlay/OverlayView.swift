import AppKit

final class OverlayView: NSView {
    private let closeHandler: () -> Void
    private let closeButton = NSButton()
    private var trackingArea: NSTrackingArea?

    init(onClose: @escaping () -> Void) {
        closeHandler = onClose
        super.init(frame: .zero)

        wantsLayer = true
        layer?.backgroundColor = NSColor.black.cgColor
        setupCloseButton()
        updateTrackingArea()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var acceptsFirstResponder: Bool { true }

    override var mouseDownCanMoveWindow: Bool { true }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        window?.makeFirstResponder(self)
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        updateTrackingArea()
    }

    override func layout() {
        super.layout()
        closeButton.frame = CGRect(
            x: bounds.maxX - 32,
            y: bounds.maxY - 32,
            width: 24,
            height: 24
        )
    }

    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        showCloseButton()
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        hideCloseButton()
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 {
            closeHandler()
        } else {
            super.keyDown(with: event)
        }
    }

    private func setupCloseButton() {
        closeButton.isBordered = false
        closeButton.isHidden = true
        closeButton.alphaValue = 0
        closeButton.image = NSImage(
            systemSymbolName: "xmark",
            accessibilityDescription: "关闭"
        )
        closeButton.imageScaling = .scaleProportionallyDown
        closeButton.contentTintColor = .white
        closeButton.toolTip = "关闭"
        closeButton.target = self
        closeButton.action = #selector(closeButtonPressed)
        closeButton.wantsLayer = true
        closeButton.layer?.backgroundColor = NSColor(calibratedWhite: 0.25, alpha: 0.95).cgColor
        closeButton.layer?.cornerRadius = 12
        addSubview(closeButton)
    }

    private func updateTrackingArea() {
        if let trackingArea {
            removeTrackingArea(trackingArea)
        }

        let hotZone = CGRect(x: max(0, bounds.maxX - 48), y: max(0, bounds.maxY - 48), width: 48, height: 48)
        let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeInKeyWindow, .inVisibleRect]
        trackingArea = NSTrackingArea(rect: hotZone, options: options, owner: self, userInfo: nil)
        if let trackingArea {
            addTrackingArea(trackingArea)
        }
    }

    private func showCloseButton() {
        closeButton.isHidden = false
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.12
            closeButton.animator().alphaValue = 1
        }
    }

    private func hideCloseButton() {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.16
            closeButton.animator().alphaValue = 0
        }, completionHandler: { [weak self] in
            Task { @MainActor [weak self] in
                self?.closeButton.isHidden = true
            }
        })
    }

    @objc private func closeButtonPressed() {
        closeHandler()
    }
}
