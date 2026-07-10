import CoreGraphics
import XCTest
@testable import OverlayCore

final class OverlayGeometryTests: XCTestCase {
    func testInitialFrameUsesScreenshotInspiredLowerHalf() {
        let screen = CGRect(x: 0, y: 0, width: 1920, height: 1280)

        let frame = OverlayGeometry.initialFrame(in: screen)

        XCTAssertEqual(frame.width, 960, accuracy: 0.1)
        XCTAssertEqual(frame.height, 115.2, accuracy: 0.1)
        XCTAssertEqual(frame.midX, screen.midX, accuracy: 0.1)
        XCTAssertEqual(frame.minY, 128, accuracy: 0.1)
    }

    func testInitialFrameRespectsMinimumsOnSmallScreen() {
        let screen = CGRect(x: 0, y: 0, width: 800, height: 600)

        let frame = OverlayGeometry.initialFrame(in: screen)

        XCTAssertGreaterThanOrEqual(frame.width, 480)
        XCTAssertGreaterThanOrEqual(frame.height, 70)
        XCTAssertTrue(screen.contains(frame))
    }

    func testClampedFrameRestoresMinimumSizeAndVisiblePosition() {
        let screen = CGRect(x: 100, y: 50, width: 1200, height: 800)
        let savedFrame = CGRect(x: -500, y: 900, width: 20, height: 30)

        let frame = OverlayGeometry.clampedFrame(savedFrame, to: screen)

        XCTAssertEqual(frame.size, CGSize(width: 480, height: 70))
        XCTAssertEqual(frame.minX, screen.minX, accuracy: 0.1)
        XCTAssertEqual(frame.maxY, screen.maxY, accuracy: 0.1)
    }
}
