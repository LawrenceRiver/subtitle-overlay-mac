# 字幕遮挡条

一个轻量的 macOS 原生悬浮窗口，用来遮住视频底部的中文字幕。

## 使用

双击 `outputs/SubtitleOverlay.app` 启动。首次启动会在屏幕下方字幕区域显示一条纯黑横条。

- 在黑色区域任意位置拖动，可以移动横条。
- 从横条四边拖动，可以自由调整宽度和高度。
- 鼠标移到右上角，会出现关闭按钮。
- 按 `Esc` 可以关闭应用。
- 关闭后会记住上次的位置和尺寸，下次启动自动恢复。

窗口会尝试保持在其他 App 和 macOS 全屏空间之上。部分受保护的视频画面、DRM 内容或系统级安全界面可能不允许第三方窗口覆盖，这是 macOS 的限制。

## 从源码重新打包

需要 macOS、Xcode Command Line Tools 和 Swift：

```bash
bash scripts/package-app.sh
```

产物位于 `outputs/SubtitleOverlay.app`。
