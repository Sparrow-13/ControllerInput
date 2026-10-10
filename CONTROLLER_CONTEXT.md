# 8BitDo Ultimate 2C --- AutoHotkey Controller Context

## Purpose

This AutoHotkey v2 script turns an 8BitDo Ultimate 2C controller into a
lightweight Windows desktop controller. It supports mouse movement,
clicks, scrolling, keyboard shortcuts, window management, media
controls, and automatic fullscreen-game detection.

## Requirements

-   Windows 10 or Windows 11
-   AutoHotkey **v2.0** (v1 is not compatible)
-   8BitDo Ultimate 2C connected and recognized by Windows
-   Optional: `controller.ico` in the same folder as the `.ahk` script
    for a custom tray icon

The script requests Administrator permission at startup so it can
interact with elevated windows.

## Main behaviour

-   Polls controller axes every 12 ms.
-   Uses the left stick for mouse movement with a configurable deadzone.
-   Uses the right stick for vertical and horizontal scrolling.
-   Uses L4 as a modifier for precision mouse movement and utility
    shortcuts.
-   Uses R4 as a modifier for window-management shortcuts and the touch
    keyboard.
-   Detects likely fullscreen games and suspends desktop mouse/control
    actions while a game is active.
-   Supports a manual forced game mode toggle.
-   Shows temporary tooltips for actions; these can be disabled.

## Button mappings

### Standalone desktop controls

  Controller input   Action
  ------------------ ---------------------------------
  A                  Left mouse button; hold to drag
  B                  Escape
  X                  Right mouse button
  Y                  Enter
  LB                 Browser Back (`Alt+Left`)
  RB                 Browser Forward (`Alt+Right`)
  Select             Start menu
  Start              Action Center (`Win+A`)

### Hold L4, then press

  Controller input   Action
  ------------------ -----------------------------------------
  L4 + A             Middle mouse click
  L4 + B             Close active window (`Alt+F4`)
  L4 + X             Copy (`Ctrl+C`)
  L4 + Y             Paste (`Ctrl+V`)
  L4 + LB            Previous browser tab (`Ctrl+Shift+Tab`)
  L4 + RB            Next browser tab (`Ctrl+Tab`)
  L4 + Start         Run dialog (`Win+R`)
  L4 + D-pad Up      Volume up
  L4 + D-pad Down    Volume down
  L4 + D-pad Left    Mute/unmute
  L4 + D-pad Right   Play/pause
  L4 + Select        Toggle action tooltips
  L4 + R4            Toggle forced game mode / desktop mode

### Hold R4, then press

  Controller input   Action
  ------------------ --------------------------------------
  R4 + A             Task View (`Win+Tab`)
  R4 + B             Show Desktop (`Win+D`)
  R4 + Y             Toggle Windows Modern Touch Keyboard
  R4 + LB            Previous window (`Alt+Shift+Tab`)
  R4 + RB            Next window (`Alt+Tab`)

### Analog controls

-   **Left stick:** moves the mouse cursor.
-   **Hold L4 + left stick:** uses the lower precision speed.
-   **Right stick:** smooth vertical/horizontal scrolling.
-   **Triggers:** the script maps thresholds on `JoyZ` to left/right
    mouse button actions. Actual axis behaviour can vary by controller
    mode and driver.

## Modern Touch Keyboard implementation

The keyboard toggle uses Windows' `ITipInvocation` COM interface. This
avoids sending `Win+Ctrl+O`, which can be intercepted by browser
shortcuts.

The function currently uses the COM class ID
`{4CE576FA-83DC-4F88-951C-9D0782B4E376}`, interface ID
`{37C994E7-432B-4834-A2F7-DCE1F13B834B}`, and
`ComCall(3, tip, "Ptr", WinExist("A"))` to toggle the keyboard.

Do not replace this with a `Win+Ctrl+O` keystroke unless intentionally
changing the design. Launching `TabTip.exe` alone may start the process
without making the keyboard visible on every Windows build.

## Configuration

These global values control the main behaviour:

``` autohotkey
global Deadzone := 0.20
global BaseSpeed := 26
global FineSpeed := 12
global PollingRate := 12
global ForceGameMode := false
global IsInGame := false
global ShowActionOverlay := true
```

-   `Deadzone`: stick movement below this normalized magnitude is
    ignored.
-   `BaseSpeed`: normal left-stick mouse speed.
-   `FineSpeed`: slower mouse speed while L4 is held.
-   `PollingRate`: controller polling timer interval in milliseconds.
-   `ForceGameMode`: when enabled, desktop controller actions are
    suspended.
-   `ShowActionOverlay`: enables/disables action tooltips.

## Installation and usage

1.  Install AutoHotkey v2.0 from the official AutoHotkey website:
    https://www.autohotkey.com/
2.  Connect the 8BitDo Ultimate 2C and verify Windows detects it.
3.  Create a folder for the script, for example
    `Documents\ControllerMouse`.
4.  Save the complete script as `controller.ahk` in that folder. Ensure
    it is the updated version with the working `ITipInvocation`
    implementation for `ToggleModernOSK()`.
5.  Optionally put `controller.ico` in the same folder.
6.  Double-click `controller.ahk`.
7.  Approve the Windows UAC prompt if asked. The script self-elevates
    because it uses `Run '*RunAs ...'`.
8.  Test the standalone buttons, sticks, and modifier combos listed
    above.
9.  To stop the script, right-click its green AutoHotkey tray icon and
    choose **Exit**.
10. To apply edits, save the `.ahk` file, then right-click the tray icon
    and choose **Reload Script**.

## Troubleshooting

### The script will not start

-   Confirm AutoHotkey v2.0 is installed; v1 will not run this script.
-   Right-click the `.ahk` file and choose **Run Script**.
-   If a syntax error appears, copy the full error text and line number.

### R4 + Y tooltip appears but keyboard does not toggle

-   Verify the `ToggleModernOSK()` function still uses the working
    `ITipInvocation` COM implementation.
-   Ensure the function uses `ComCall(3, tip, "Ptr", WinExist("A"))`.
-   Do not use a keyboard shortcut for the toggle; browsers may
    intercept it.

### Controller buttons do not respond

-   Confirm the controller is connected and recognized by Windows.
-   Check that the controller's active mode exposes the expected
    joystick buttons/axes.
-   Use AutoHotkey's built-in key history/joystick state tools to verify
    button numbers if the controller mode changes.

### Scrolling or triggers behave incorrectly

-   Controller drivers and controller modes can expose axes differently.
-   The current script uses `JoyU` or falls back to `JoyZ` for
    horizontal scrolling, while trigger handling also reads `JoyZ`. If
    the controller exposes only `JoyZ`, horizontal scroll and trigger
    input may conflict. Adjust the axis mapping after checking actual
    controller axis values.

### Fullscreen game detection is incorrect

-   The script detects likely games using fullscreen window size and
    style, with exclusions for common browsers and media players.
-   Borderless fullscreen, unusual window sizes, or games with different
    window styles may be misdetected.
-   Use `L4 + R4` to force game mode or return to desktop mode.

## Notes for future edits

-   Keep the script compatible with AutoHotkey v2.0.
-   Preserve the user's existing button mappings unless explicitly asked
    to change them.
-   Do not introduce `Win+Ctrl+O` for the touch keyboard; browser
    shortcuts can intercept it.
-   The user prefers concise, practical instructions and minimal
    unrelated changes.
