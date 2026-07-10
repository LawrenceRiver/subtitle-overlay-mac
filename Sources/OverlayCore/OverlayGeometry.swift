import CoreGraphics

public enum OverlayGeometry {
    public static let defaultMinimumSize = CGSize(width: 480, height: 70)

    public static func initialFrame(in screen: CGRect) -> CGRect {
        let width = min(max(screen.width * 0.50, defaultMinimumSize.width), 1200)
        let height = min(max(screen.height * 0.09, defaultMinimumSize.height), 180)
        let bottomInset = screen.height * 0.10

        return CGRect(
            x: screen.midX - width / 2,
            y: screen.minY + bottomInset,
            width: width,
            height: height
        )
    }

    public static func clampedFrame(
        _ frame: CGRect,
        to screen: CGRect,
        minimumSize: CGSize = defaultMinimumSize
    ) -> CGRect {
        let minimumWidth = min(minimumSize.width, screen.width)
        let minimumHeight = min(minimumSize.height, screen.height)
        let width = min(max(frame.width, minimumWidth), screen.width)
        let height = min(max(frame.height, minimumHeight), screen.height)
        let x = min(max(frame.minX, screen.minX), screen.maxX - width)
        let y = min(max(frame.minY, screen.minY), screen.maxY - height)

        return CGRect(x: x, y: y, width: width, height: height)
    }
}
