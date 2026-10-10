
#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent()

; Auto-elevate to Administrator
if !A_IsAdmin {
    try {
        Run '*RunAs "' A_ScriptFullPath '"'
        ExitApp
    }
}

; Custom Tray Icon
if FileExist(A_ScriptDir "\controller.ico")
    TraySetIcon A_ScriptDir "\controller.ico"

; ================= CONFIGURATION =================

global Deadzone := 0.20
global BaseSpeed := 26
global FineSpeed := 12
global PollingRate := 12

global ForceGameMode := false
global IsInGame := false
global ShowActionOverlay := true

SetTimer ControllerLoop, PollingRate

; ================= HELPER FUNCTIONS =================

LogAction(actionText) {
    global ShowActionOverlay, IsInGame, ForceGameMode

    if (ShowActionOverlay && !IsInGame && !ForceGameMode) {
        ToolTip actionText
        SetTimer () => ToolTip(), -1000
    }
}

ToggleGameMode() {
    global ForceGameMode

    ForceGameMode := !ForceGameMode

    ToolTip(ForceGameMode
        ? "Mode: FORCED GAME MODE (Mouse OFF)"
        : "Mode: DESKTOP MOUSE (Active)")

    SetTimer () => ToolTip(), -2000
}

; ================= MODERN TOUCH KEYBOARD =================


; ================= MODERN TOUCH KEYBOARD =================

ToggleModernOSK() {
    try {
        ; Windows Modern Touch Keyboard toggle interface
        tip := ComObject(
            "{4CE576FA-83DC-4F88-951C-9D0782B4E376}",
            "{37C994E7-432B-4834-A2F7-DCE1F13B834B}"
        )

        ; ITipInvocation::Toggle(active window)
        ComCall(3, tip, "Ptr", WinExist("A"))

        LogAction("Keyboard: Toggle requested")
    } catch as err {
        ToolTip("Keyboard toggle failed: " err.Message)
        SetTimer () => ToolTip(), -3000
    }
}


; ================= GAME DETECTION =================

IsGameActive() {
    activeHwnd := WinActive("A")

    if !activeHwnd
        return false

    activeClass := WinGetClass(activeHwnd)
    activeProcess := WinGetProcessName(activeHwnd)

    ; Exclude standard Windows shell elements.
    if (activeClass ~= "i)^(Progman|WorkerW|Shell_TrayWnd|Shell_SecondaryTrayWnd|CabinetWClass|Windows\.UI\.Core\.CoreWindow)$")
        return false

    ; Exclude browsers and media players.
    if (activeProcess ~= "i)^(chrome\.exe|msedge\.exe|firefox\.exe|brave\.exe|opera\.exe|vlc\.exe|mpc-hc.*\.exe|potplayer.*\.exe)$")
        return false

    try {
        WinGetPos(&wx, &wy, &ww, &wh, activeHwnd)

        if (wx == 0 && wy == 0
            && ww == A_ScreenWidth
            && wh == A_ScreenHeight) {

            style := WinGetStyle(activeHwnd)

            ; Fullscreen window without resize border.
            if !(style & 0x00040000)
                return true
        }
    }

    return false
}

IsDesktopControlActive() {
    global ForceGameMode, IsInGame
    return (!ForceGameMode && !IsInGame)
}

; ================= CONTROLLER HOTKEYS =================

; --- 1. GLOBAL OVERRIDES: HOLD L4 / JOY9 ---

#HotIf GetKeyState("Joy9")

; L4 + R4: Toggle forced game / desktop mode
Joy10::ToggleGameMode()

; L4 + Select: Toggle action notifications
Joy7:: {
    global ShowActionOverlay

    ShowActionOverlay := !ShowActionOverlay

    ToolTip(ShowActionOverlay
        ? "Action Overlay: ON"
        : "Action Overlay: OFF")

    SetTimer () => ToolTip(), -1500
}

#HotIf

; --- 2. R4 COMBOS: HOLD R4 / JOY10 ---

#HotIf GetKeyState("Joy10") && IsDesktopControlActive()

; R4 + Y: Modern Touch Keyboard
Joy4::ToggleModernOSK()

; R4 + RB: Next window
Joy6:: {
    Send "!{Tab}"
    LogAction("Task: Next Window (Alt+Tab)")
}

; R4 + LB: Previous window
Joy5:: {
    Send "!+{Tab}"
    LogAction("Task: Previous Window")
}

; R4 + A: Task View
Joy1:: {
    Send "#{Tab}"
    LogAction("Windows: Task View")
}

; R4 + B: Show Desktop
Joy2:: {
    Send "#d"
    LogAction("Windows: Show Desktop")
}

#HotIf

; --- 3. L4 COMBOS: DESKTOP UTILITIES ---

#HotIf GetKeyState("Joy9") && IsDesktopControlActive()

; L4 + A: Middle click
Joy1:: {
    Click "Middle"
    LogAction("Mouse: Middle Click")
}

; L4 + B: Close window
Joy2:: {
    Send "!{F4}"
    LogAction("Shortcut: Close Window")
}

; L4 + X: Copy
Joy3:: {
    Send "^c"
    LogAction("Clipboard: Copy")
}

; L4 + Y: Paste
Joy4:: {
    Send "^v"
    LogAction("Clipboard: Paste")
}

; L4 + LB: Previous browser tab
Joy5:: {
    Send "^+{Tab}"
    LogAction("Tab: Previous")
}

; L4 + RB: Next browser tab
Joy6:: {
    Send "^{Tab}"
    LogAction("Tab: Next")
}

; L4 + Start: Run dialog
Joy8:: {
    Send "#r"
    LogAction("Windows: Run")
}

#HotIf

; --- 4. SOLO DESKTOP BUTTONS ---

#HotIf !GetKeyState("Joy9") && !GetKeyState("Joy10") && IsDesktopControlActive()

; A: Left click and drag
Joy1:: {
    Click "Down"
    LogAction("Mouse: Drag")
}

Joy1 Up::Click "Up"

; B: Escape
Joy2:: {
    Send "{Esc}"
    LogAction("Key: Escape")
}

; X: Right click
Joy3:: {
    Click "Right Down"
    LogAction("Mouse: Right Click")
}

Joy3 Up::Click "Right Up"

; Y: Enter
Joy4:: {
    Send "{Enter}"
    LogAction("Key: Enter")
}

; LB: Browser back
Joy5:: {
    Send "!{Left}"
    LogAction("Navigation: Back")
}

; RB: Browser forward
Joy6:: {
    Send "!{Right}"
    LogAction("Navigation: Forward")
}

; Select: Start menu
Joy7:: {
    Send "{LWin}"
    LogAction("Windows: Start Menu")
}

; Start: Action Center
Joy8:: {
    Send "#a"
    LogAction("Windows: Action Center")
}

#HotIf

; ================= ANALOG STICK, TRIGGERS & D-PAD =================

ControllerLoop() {
    global ForceGameMode, IsInGame
    global Deadzone, BaseSpeed, FineSpeed

    ; Check fullscreen game status periodically.
    static checkInterval := 0

    if (++checkInterval > 30) {
        checkInterval := 0

        wasInGame := IsInGame
        IsInGame := IsGameActive()

        if (!ForceGameMode && wasInGame != IsInGame) {
            ToolTip(IsInGame
                ? "Auto-Switched: Game Mode"
                : "Auto-Switched: Desktop Mouse")

            SetTimer () => ToolTip(), -1500
        }
    }

    ; Disable desktop controls in game mode.
    if (ForceGameMode || IsInGame)
        return

    isL4Held := GetKeyState("Joy9")
    currentSpeed := isL4Held ? FineSpeed : BaseSpeed

    ; ----- 1. LEFT STICK: MOUSE MOVEMENT -----

    x := GetKeyState("JoyX")
    y := GetKeyState("JoyY")

    if (x != "" && y != "") {
        normX := (x - 50) / 50.0
        normY := (y - 50) / 50.0

        mag := Sqrt(normX**2 + normY**2)

        if (mag > Deadzone) {
            scale := (mag - Deadzone) / (1.0 - Deadzone)

            deltaX := (normX / mag) * scale * currentSpeed
            deltaY := (normY / mag) * scale * currentSpeed

            MouseMove Round(deltaX), Round(deltaY), 0, "R"
        }
    }

    ; ----- 2. RIGHT STICK: SMOOTH 2D SCROLLING -----

    rY := GetKeyState("JoyR")

    ; Prefer JoyU for horizontal scroll, otherwise JoyZ.
    rX := GetKeyState("JoyU") != ""
        ? GetKeyState("JoyU")
        : GetKeyState("JoyZ")

    static scrollAccumulatorY := 0.0
    static scrollAccumulatorX := 0.0

    ; Vertical scroll
    if (rY != "") {
        normY := (rY - 50) / 50.0

        if (Abs(normY) > Deadzone) {
            signY := normY > 0 ? 1 : -1

            deflectionY :=
                (Abs(normY) - Deadzone) / (1.0 - Deadzone)

            accelY := (deflectionY ** 3.2) * 0.18
            scrollAccumulatorY += accelY

            while (scrollAccumulatorY >= 1.0) {
                if (signY > 0)
                    Click "WheelDown"
                else
                    Click "WheelUp"

                scrollAccumulatorY -= 1.0
            }
        } else {
            scrollAccumulatorY := 0.0
        }
    }

    ; Horizontal scroll
    if (rX != "") {
        normX := (rX - 50) / 50.0

        if (Abs(normX) > Deadzone) {
            signX := normX > 0 ? 1 : -1

            deflectionX :=
                (Abs(normX) - Deadzone) / (1.0 - Deadzone)

            accelX := (deflectionX ** 3.2) * 0.14
            scrollAccumulatorX += accelX

            while (scrollAccumulatorX >= 1.0) {
                if (signX > 0)
                    Send "+{WheelDown}"
                else
                    Send "+{WheelUp}"

                scrollAccumulatorX -= 1.0
            }
        } else {
            scrollAccumulatorX := 0.0
        }
    }

    ; ----- 3. ANALOG TRIGGERS: JOYZ AXIS -----

    z := GetKeyState("JoyZ")

    static ltPressed := false
    static rtPressed := false

    if (z != "") {
        ; RT: Left click / drag
        if (z < 30 && !rtPressed) {
            rtPressed := true
            Click "Down"
        } else if (z >= 30 && rtPressed) {
            rtPressed := false
            Click "Up"
        }

        ; LT: Right click
        if (z > 70 && !ltPressed) {
            ltPressed := true
            Click "Right Down"
        } else if (z <= 70 && ltPressed) {
            ltPressed := false
            Click "Right Up"
        }
    }

    ; ----- 4. D-PAD + L4: MEDIA / VOLUME -----

    pov := GetKeyState("JoyPOV")
    static dpadHoldCounter := 0

    if (pov != -1 && isL4Held) {
        if (++dpadHoldCounter >= 7) {
            dpadHoldCounter := 0

            ; Up: Volume up
            if (pov == 0) {
                Send "{Volume_Up 2}"
                LogAction("Audio: Volume Up")

            ; Down: Volume down
            } else if (pov == 18000) {
                Send "{Volume_Down 2}"
                LogAction("Audio: Volume Down")

            ; Left: Mute
            } else if (pov == 27000) {
                Send "{Volume_Mute}"
                LogAction("Audio: Mute Toggle")

            ; Right: Play / pause
            } else if (pov == 9000) {
                Send "{Media_Play_Pause}"
                LogAction("Media: Play / Pause")
            }
        }
    } else {
        dpadHoldCounter := 6
    }
}
