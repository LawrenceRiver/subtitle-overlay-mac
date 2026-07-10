# 字幕遮挡条 macOS 应用 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build and package a native macOS app that displays a black, always-on-top, draggable and resizable subtitle-blocking window.

**Architecture:** A small Swift Package will contain an `OverlayCore` library for pure geometry calculations, an AppKit executable for the application delegate, custom borderless overlay window, and hover-close view, plus XCTest coverage for the reusable geometry. A packaging script will place the release executable and Info.plist into a double-clickable `.app` bundle.

**Tech Stack:** Swift 6.3, Swift Package Manager, AppKit, XCTest, macOS 13+ deployment target, arm64 release build.

## Global Constraints

- The overlay is pure black, opaque, borderless, and has no permanent toolbar.
- The first launch uses a screenshot-inspired size near half the current screen width and the lower subtitle area.
- The window stays above normal applications and joins all Spaces with full-screen auxiliary behavior.
- The user can drag from the black area, resize from window edges, close from a hover-revealed top-right button, or press `Esc`.
- The last valid window frame is stored and restored on the next launch.
- The deliverable includes source code and a double-clickable `.app`.
- The app does not read screen contents, use network access, or require accessibility permission.

---

### Task 1: Create the Swift package and pure frame logic

**Files:**
- Create: `/Users/lawrenceriver/Documents/Codex/2026-07-10/new-chat/Package.swift`
- Create: `/Users/lawrenceriver/Documents/Codex/2026-07-10/new-chat/Sources/OverlayCore/OverlayGeometry.swift`
- Create: `/Users/lawrenceriver/Documents/Codex/2026-07-10/new-chat/Tests/SubtitleOverlayTests/OverlayGeometryTests.swift`

**Interfaces:**
- Produces `OverlayGeometry.initialFrame(in:) -> CGRect` and `OverlayGeometry.clampedFrame(_:to:minimumSize:) -> CGRect` from the `OverlayCore` library for the AppKit layer and tests.

- [ ] **Step 1: Write the package manifest and tests**

`Package.swift` must define a library target named `OverlayCore`, an executable target named `SubtitleOverlay` that depends on `OverlayCore`, and a test target named `SubtitleOverlayTests` that depends on `OverlayCore`, with macOS 13 as the platform floor.

The tests must cover a screenshot-inspired default frame, minimum-size enforcement, and clamping a saved frame back onto a visible screen.

- [ ] **Step 2: Run the tests to verify the geometry API is absent**

Run:

```bash
swift test
```

Expected: compilation fails because `OverlayGeometry` has not been created yet.

- [ ] **Step 3: Implement the geometry helper**

Implement these exact behaviors in `OverlayCore`:

```swift
enum OverlayGeometry {
    static func initialFrame(in screen: CGRect) -> CGRect
    static func clampedFrame(_ frame: CGRect, to screen: CGRect, minimumSize: CGSize) -> CGRect
}
```

Use a width of `screen.width * 0.50`, a height of `screen.height * 0.09`, minimums of `480 x 70`, maximums of `1200 x 180`, horizontal centering, and a bottom inset of `screen.height * 0.10`.

- [ ] **Step 4: Run the tests to verify the helper**

Run:

```bash
swift test
```

Expected: all geometry tests pass.

- [ ] **Step 5: Commit the package foundation**

```bash
git add Package.swift Sources/SubtitleOverlay/OverlayGeometry.swift Tests/SubtitleOverlayTests/OverlayGeometryTests.swift
git commit -m "feat: add overlay geometry foundation"
```

### Task 2: Implement the native always-on-top overlay window

**Files:**
- Create: `/Users/lawrenceriver/Documents/Codex/2026-07-10/new-chat/Sources/SubtitleOverlay/AppDelegate.swift`
- Create: `/Users/lawrenceriver/Documents/Codex/2026-07-10/new-chat/Sources/SubtitleOverlay/OverlayWindow.swift`
- Create: `/Users/lawrenceriver/Documents/Codex/2026-07-10/new-chat/Sources/SubtitleOverlay/OverlayView.swift`
- Create: `/Users/lawrenceriver/Documents/Codex/2026-07-10/new-chat/Sources/SubtitleOverlay/main.swift`

**Interfaces:**
- `OverlayWindow(frame: CGRect, onClose: @escaping () -> Void)` owns the borderless AppKit window.
- `OverlayView(onClose: @escaping () -> Void)` draws the black surface and hover close button.
- `AppDelegate` owns the single window lifecycle and frame persistence.

- [ ] **Step 1: Implement `OverlayWindow`**

Create an `NSWindow` with `.borderless` and `.resizable` style masks. Set `isOpaque = true`, `backgroundColor = .black`, `hasShadow = false`, `level = .screenSaver`, `collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]`, `isMovableByWindowBackground = true`, and a minimum content size of `480 x 70`.

Override `canBecomeKey` and `canBecomeMain` to return `true`, and install an `OverlayView` as the content view.

- [ ] **Step 2: Implement `OverlayView`**

Draw a solid black background. Add an `NSTrackingArea` for a 32-point top-right hot zone. Keep the close button hidden by default, fade it in on `mouseEntered`, fade it out on `mouseExited`, and make it a 24-point circular dark-gray button with a white `xmark` symbol. Clicking it invokes `onClose`.

The view must accept first responder status and intercept `keyDown`; when the key is `Esc`, call `onClose`, otherwise pass the event to `super`.

- [ ] **Step 3: Implement `AppDelegate` and application entry point**

Create the app as a regular accessory application so it does not add a Dock icon. Read a saved `NSRect` from `UserDefaults` using four scalar keys. If no valid saved frame exists, call `OverlayGeometry.initialFrame(in: NSScreen.main?.visibleFrame ?? ...)`. Clamp restored frames with `OverlayGeometry.clampedFrame`.

On close, save the current frame and terminate the application. Set the window as key, order it front, and activate the app ignoring other apps.

- [ ] **Step 4: Build the executable**

Run:

```bash
swift build -c release
```

Expected: the `SubtitleOverlay` executable compiles successfully.

- [ ] **Step 5: Commit the window implementation**

```bash
git add Sources/SubtitleOverlay
git commit -m "feat: add always-on-top subtitle overlay window"
```

### Task 3: Package and smoke-test the `.app`

**Files:**
- Create: `/Users/lawrenceriver/Documents/Codex/2026-07-10/new-chat/Resources/Info.plist`
- Create: `/Users/lawrenceriver/Documents/Codex/2026-07-10/new-chat/scripts/package-app.sh`
- Create: `/Users/lawrenceriver/Documents/Codex/2026-07-10/new-chat/README.md`
- Create: `/Users/lawrenceriver/Documents/Codex/2026-07-10/new-chat/outputs/SubtitleOverlay.app` (generated bundle)

**Interfaces:**
- `scripts/package-app.sh` consumes the release build and produces `outputs/SubtitleOverlay.app`.
- `README.md` documents launch and controls in Chinese.

- [ ] **Step 1: Add bundle metadata and packaging script**

Create an `Info.plist` with `CFBundleExecutable=SubtitleOverlay`, `CFBundleIdentifier=com.codex.subtitle-overlay`, `CFBundlePackageType=APPL`, `LSUIElement=true`, and `NSHighResolutionCapable=true`.

The packaging script must use `set -euo pipefail`, run `swift build -c release`, create `outputs/SubtitleOverlay.app/Contents/MacOS` and `Contents/Resources`, copy the executable and plist, write `APPL????` to `PkgInfo`, and mark the executable as executable.

- [ ] **Step 2: Package the app**

Run:

```bash
bash scripts/package-app.sh
```

Expected: `outputs/SubtitleOverlay.app` exists and `file outputs/SubtitleOverlay.app/Contents/MacOS/SubtitleOverlay` reports a Mach-O arm64 executable.

- [ ] **Step 3: Add user instructions**

Document double-click launch, drag, edge resize, hover-close, `Esc`, restored position, and the note that some protected video surfaces may ignore all third-party overlay windows.

- [ ] **Step 4: Run launch and process smoke tests**

Run:

```bash
open outputs/SubtitleOverlay.app
pgrep -f 'outputs/SubtitleOverlay.app/Contents/MacOS/SubtitleOverlay'
```

Expected: the app launches without a crash and a matching process is present. Use a short AppleScript or manual UI pass to send `Esc`; then confirm the process exits.

- [ ] **Step 5: Verify persistence with a relaunch**

Launch the app, move or resize it manually, close with `Esc`, relaunch, and confirm the window frame is restored. If UI automation is unavailable, record the manual verification result in the final handoff.

- [ ] **Step 6: Commit the packaged deliverable**

```bash
git add Resources scripts README.md outputs/SubtitleOverlay.app
git commit -m "build: package subtitle overlay app"
```

### Task 4: Final verification and handoff

**Files:**
- Verify: `/Users/lawrenceriver/Documents/Codex/2026-07-10/new-chat/docs/superpowers/specs/2026-07-10-subtitle-overlay-design.md`
- Verify: `/Users/lawrenceriver/Documents/Codex/2026-07-10/new-chat/docs/superpowers/plans/2026-07-10-subtitle-overlay.md`

- [ ] **Step 1: Run the complete verification suite**

Run:

```bash
swift test
bash scripts/package-app.sh
git status --short
```

Expected: tests pass, packaging succeeds, and only intentionally generated or committed files remain.

- [ ] **Step 2: Inspect the final bundle**

Run:

```bash
plutil -p outputs/SubtitleOverlay.app/Contents/Info.plist
codesign --display --verbose=2 outputs/SubtitleOverlay.app 2>&1 | head -20
```

Expected: plist values are present; ad-hoc signing may be absent or present depending on local tooling, but the bundle remains launchable.

- [ ] **Step 3: Report exact deliverables and any manual-only checks**

Provide clickable links to the `.app`, source directory, README, and design spec. Clearly distinguish automated test results from manual UI verification.
