# ControllerInput

**Turn your 8BitDo Ultimate 2C into a Windows desktop controller.**

A lightweight AutoHotkey v2 script for mouse control, scrolling, shortcuts, media controls, and more — without running a heavy background application.

## Features

- 🖱️ **Analog Mouse Control** — Move the cursor using the left stick.
- ↕️ **Smooth Scrolling** — Scroll vertically and horizontally with the right stick.
- 🎮 **Controller Shortcuts** — Click, drag, copy, paste, navigate, and manage windows.
- ⌨️ **Modern Touch Keyboard** — Toggle the Windows touch keyboard directly from the controller.
- 🔊 **Media Controls** — Adjust volume, mute, and control playback.
- 🎯 **Automatic Game Detection** — Suspend desktop controls when a fullscreen game is detected.
- ⚡ **On-the-Fly Mode Switching** — Switch between desktop and game mode instantly.
- 🔧 **Configurable Controls** — Adjust cursor speed, deadzone, and polling interval.

## Lightweight by Design

- **Negligible intended resource overhead** compared with a full desktop-control application.
- No heavy GUI or continuously running helper application is required.
- Uses a small AutoHotkey script with configurable polling.
- Actual CPU and RAM usage depends on the system, polling interval, and active controller inputs.

*Resource usage has not been benchmarked; exact CPU and memory figures are intentionally omitted.*

## Requirements

- **Target device:** 8BitDo Ultimate 2C
- Windows 10 / 11
- [AutoHotkey v2](https://www.autohotkey.com/)

## Installation

1. Install AutoHotkey v2.
2. Connect your 8BitDo Ultimate 2C.
3. Clone or download this repository.
4. Run `controller.ahk`.
5. Approve the administrator prompt if requested.

## Controls

| Input | Action |
|---|---|
| Left Stick | Move cursor |
| Right Stick | Vertical / horizontal scrolling |
| A | Left click / drag |
| B | Escape |
| X | Right click |
| Y | Enter |
| LB / RB | Browser back / forward |
| L4 + A | Middle click |
| L4 + B | Close window |
| L4 + X / Y | Copy / paste |
| L4 + LB / RB | Previous / next browser tab |
| L4 + Start | Open Run dialog |
| L4 + D-pad | Volume and media controls |
| L4 + Select | Toggle action notifications |
| R4 + A / B | Task View / Show Desktop |
| R4 + Y | Toggle Modern Touch Keyboard |
| R4 + LB / RB | Switch windows |
| L4 + R4 | Toggle game / desktop mode |

## On-the-Fly Control

- **Desktop mode:** Use the controller to navigate Windows.
- **Game mode:** Suspend desktop mouse and shortcut handling.
- **Manual toggle:** Press `L4 + R4` to switch modes immediately.
- **Notifications:** Toggle action tooltips using `L4 + Select`.
- **Exit or reload:** Use the AutoHotkey tray icon to exit or reload the script.

## Configuration

Edit these values near the top of `controller.ahk`:

```autohotkey
global Deadzone := 0.20
global BaseSpeed := 26
global FineSpeed := 12
global PollingRate := 12
```

| Setting | Purpose |
|---|---|
| `Deadzone` | Minimum stick movement before input registers |
| `BaseSpeed` | Normal cursor speed |
| `FineSpeed` | Slower cursor speed while holding L4 |
| `PollingRate` | Controller polling interval in milliseconds |

## Troubleshooting

- **Script does not start:** Ensure AutoHotkey v2 is installed.
- **Keyboard does not toggle:** Preserve the working `ITipInvocation` implementation.
- **Controls behave differently:** Check controller mode and joystick axis mappings.
- **Changes do not apply:** Reload the script from the AutoHotkey tray icon.

## License

Add a license file before distributing or accepting contributions.
