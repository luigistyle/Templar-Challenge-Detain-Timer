; Script created by luigistyle
; Detain timings by Enskeria
; Instabreak detain timings by Shadow Rizzard

#Requires AutoHotkey v2.0
#SingleInstance Force
SetWorkingDir A_InitialWorkingDir
#Include Lib\_JXON.ahk

; ToggleMonitorScaling
global ScreenSizeCoefficient
ScreenSizeCoefficient := A_ScreenWidth/1920

AdjustedDetainFontSize := 50*ScreenSizeCoefficient
AdjustedSettingsFontSize := 15*ScreenSizeCoefficient
AdjustedDetainGUIWidth := 100*ScreenSizeCoefficient
AdjustedDetainGUIHeight := 57*ScreenSizeCoefficient
AdjustedSettingsWidth := 400*ScreenSizeCoefficient
AdjustedSettingsHeight := 450*ScreenSizeCoefficient

; Define settings file
settingsFile := "settings.json"

; Create the settings file if it doesn't exist already
if !FileExist(settingsFile) {
	defaultSettings := '{"ToggleBackground":1,"ToggleColoredText":1,"GUIPosX":' A_ScreenWidth-AdjustedDetainGUIWidth-20 ',"GUIPosY":0,"Sound":"*-1","ToggleInstabreak":0,"ToggleMonitorScaling":1}'
	dumpDefaultSettings := Jxon_Load(&defaultSettings)
	FileAppend(Jxon_Dump(dumpDefaultSettings), settingsFile)
}

; Read and load contents of settings.json
settingsFileContent := FileRead(settingsFile)
settings := Jxon_Load(&settingsFileContent)

; Initialize Timer GUI and its variables
global DetainGUI := Gui()
hwnd := DetainGUI.Hwnd
CheckMonitorScaling()
global DetainGUIText := DetainGUI.Add("Text", "w" AdjustedDetainGUIWidth " h" AdjustedDetainGUIHeight " Center 0x200", "0")
DetainGUIText.SetFont("s" AdjustedDetainFontSize)
DetainGUI.Opt("-Caption +AlwaysOnTop +LastFound +Owner")
WinSetExStyle("+0x20|0x80000", hwnd)
CheckSettings()
DetainGUIText.Opt("+Center +0x200")
DetainGUI.Show("NoActivate X" settings["GUIPosX"] " Y" settings["GUIPosY"])

Timer(t) {
    Loop {
        if (settings["ToggleColoredText"]) {
            if (t < 5) {
                DetainGUIText.SetFont("cff0000")
            } else if (t < 10) {
                DetainGUIText.SetFont("cffcc00")
            } else if (t >= 10) {
                DetainGUIText.SetFont("c40ff00")
            }
        }    
        DetainGUIText.Value := t ; Update the GUI text
        t -= 1
        Sleep 1000
        if (t = 1) {
            SoundPlay settings["Sound"]
        } 
    } until (t <= 0)
}

CheckSettings() {
    ; Globals
    global settings, DetainGUI, DetainGUIText

    ; ToggleBackground
    if (settings["ToggleBackground"]) {
        DetainGUI.BackColor := "000000"
        WinSetTransparent(255, hwnd) ; Have to set this otherwise it isn't clickthrough
    } else {
        DetainGUI.BackColor := "010101"
        WinSetTransColor("010101", hwnd)
    }

    ; ToggleColoredText
    if (settings["ToggleColoredText"]) {
        DetainGUIText.SetFont("cff0000")
    } else {
        DetainGUIText.SetFont("cFFFFFF")
    }

    CheckMonitorScaling()
}

CheckMonitorScaling() {
    global ScreenSizeCoefficient, AdjustedDetainFontSize, AdjustedSettingsFontSize, AdjustedDetainGUIHeight, AdjustedDetainGUIWidth, AdjustedSettingsWidth, AdjustedSettingsHeight
    ; ToggleMonitorScaling
    if (settings["ToggleMonitorScaling"]) {
        ScreenSizeCoefficient := A_ScreenWidth/1920
    } else {
        ScreenSizeCoefficient := 1
    }
    AdjustedDetainFontSize := 50*ScreenSizeCoefficient
    AdjustedSettingsFontSize := 15*ScreenSizeCoefficient
    AdjustedDetainGUIWidth := 100*ScreenSizeCoefficient
    AdjustedDetainGUIHeight := 57*ScreenSizeCoefficient
    AdjustedSettingsWidth := 400*ScreenSizeCoefficient
    AdjustedSettingsHeight := 450*ScreenSizeCoefficient
}

KeyTranslation(Key) {
    switch Key
    {
        case "ToggleBackground": return "Text Background"
        case "ToggleColoredText": return "Colored Text"
        case "ToggleInstabreak": return "Instant Break"
        case "ToggleMonitorScaling": return "Monitor Size Scaling"
        default: return Key
    }
}

SoundValueTranslation(Value) {
    switch Value
    {
        case "*-1": return "Default Windows Beep"
        default: 
        {
            SplitPath Value, &OutFileName, &OutDir, &OutExtension, &OutNameNoExt, &OutDrive
            ShortenedSelectedFile := SubStr(OutNameNoExt, 1, 12)
            if (StrLen(OutNameNoExt) > 12) {
                return ShortenedSelectedFile "...." OutExtension
            } else {
                return ShortenedSelectedFile "." OutExtension
            }
        }
    }
}

HandleSettingsGUIChange(control, info) {
    global settings, settingsFile, DetainGUI, DetainGUIText

    ; Get the key from the control's Name property
    key := control.Name

    if (control.Type = "CheckBox") {
        ; Get the value of the checkbox (1 for checked, 0 for unchecked)
        checkboxValue := control.Value ? 1 : 0
        ; Update the settings object with the new value
        settings[key] := checkboxValue
        if (control.Text = "Monitor Size Scaling") {
            CheckSettings()
            MsgBox("The script will now reload in order to apply this setting. `nYou may need to re-align the Detain Timer.")
            Reload
        }
    } else if (control.Type = "Slider") {
        sliderValue := control.Value
        settings[key] := sliderValue
    } else if (control.Type = "Button") {
        switch control.Text
        {
            case "Top Left": DetainGUI.Move(0, 0)
            case "Top Right": DetainGUI.Move(A_ScreenWidth-AdjustedDetainGUIWidth-20, 0)
            case "Bottom Right": DetainGUI.Move(A_ScreenWidth-AdjustedDetainGUIWidth-20, A_ScreenHeight-AdjustedDetainGUIHeight-12)
            case "Bottom Left": DetainGUI.Move(0, A_ScreenHeight-AdjustedDetainGUIHeight-12)
        }
        DetainGUI.GetClientPos(&X, &Y)
        settings["GUIPosX"] := X
        settings["GUIPosY"] := Y

    }
    WriteSettingsToFile()
    CheckSettings()
}

; Delete the old file and write the updated settings to settings.json
WriteSettingsToFile() {
    FileDelete(settingsFile)
    FileAppend(Jxon_Dump(settings), settingsFile)
}

; Initialize dragging toggle
global IsDraggable := false
EnableDragging(IsDraggable)
; Function to enable or disable dragging
EnableDragging(enable) {
    if enable {
        OnMessage(0x200, MoveDetainGUI)
        WinSetExStyle("-0x20|0x80000", hwnd)
    } else {
        WinSetExStyle("+0x20|0x80000", hwnd)
        DetainGUI.GetClientPos(&X, &Y)
        settings["GUIPosX"] := X
        settings["GUIPosY"] := Y
        WriteSettingsToFile()
    }
}

; Function to move the GUI when dragging is enabled
MoveDetainGUI(wParam, lParam, msg, hwnd) {
    static WM_NCLBUTTONDOWN := 0xA1
    MouseGetPos(, , &targetHwnd) ; Get the window handle under the cursor
    if (targetHwnd = hwnd && wParam = 1) {
        ; Simulate dragging by sending WM_NCLBUTTONDOWN to the target window
        SendMessage(WM_NCLBUTTONDOWN, 2, 0, , hwnd)
    }
}

OpenFileSelect(*) {
    global SelectedFile := FileSelect(3,,, "Audio (*.wav; *.mp3; *.ogg)" )

    if (!SelectedFile) {
        return
    }

    SplitPath SelectedFile, &OutFileName, &OutDir, &OutExtension, &OutNameNoExt, &OutDrive
    ShortenedSelectedFile := SubStr(OutNameNoExt, 1, 12)
    if (StrLen(OutNameNoExt) > 12) {
        CurrentSoundVar.Value := ShortenedSelectedFile "...." OutExtension
    } else {
        CurrentSoundVar.Value := ShortenedSelectedFile "." OutExtension
    }
    settings["Sound"] := SelectedFile
    WriteSettingsToFile()
}

ResetSound(*) {
    CurrentSoundVar.Value := "Windows Default Beep"
    settings["Sound"] := "*-1"
    WriteSettingsToFile()
}

CreateSettingsGUI() {
    static SettingsGUI
    global settings, settingsFile, DetainGUI, ScreenSizeCoefficient
    if IsSet(SettingsGUI)
        SettingsGUI.Destroy
    SettingsGUI := Gui()
    SettingsGUI.Title := "Timer Settings"
    SettingsGUI.SetFont("s" AdjustedSettingsFontSize)
    For key, value in settings {
        if (InStr(key, "Toggle")) {
            label := KeyTranslation(key)
            checkbox := SettingsGUI.Add("CheckBox", , label)  ; Add a checkbox for each setting
            checkbox.Value := value ? 1 : 0
            checkbox.Name := key
            checkbox.OnEvent("Click", HandleSettingsGUIChange)
        }    
    }
    SettingsGUI.Add("GroupBox", "y+" 15*ScreenSizeCoefficient " w" 220*ScreenSizeCoefficient " h" 185*ScreenSizeCoefficient, "Preset Alignments")
    Button_TL := SettingsGUI.Add("Button", "w" 100*ScreenSizeCoefficient " h" 60*ScreenSizeCoefficient " XP+" 5*ScreenSizeCoefficient " YP+" 35*ScreenSizeCoefficient, "Top Left")
    Button_TL.OnEvent("Click", HandleSettingsGUIChange)
    Button_TR := SettingsGUI.Add("Button", "w" 100*ScreenSizeCoefficient " h" 60*ScreenSizeCoefficient " XP+" 110*ScreenSizeCoefficient " YP", "Top Right")
    Button_TR.OnEvent("Click", HandleSettingsGUIChange)
    Button_BR := SettingsGUI.Add("Button", "w" 100*ScreenSizeCoefficient " h" 60*ScreenSizeCoefficient " XP YP+" 70*ScreenSizeCoefficient, "Bottom Right")
    Button_BR.OnEvent("Click", HandleSettingsGUIChange)
    Button_BL := SettingsGUI.Add("Button", "w" 100*ScreenSizeCoefficient " h" 60*ScreenSizeCoefficient " XP-" 110*ScreenSizeCoefficient " YP", "Bottom Left")
    Button_BL.OnEvent("Click", HandleSettingsGUIChange)
    SettingsGUI.Add("GroupBox", "x" 20*ScreenSizeCoefficient " w" 220*ScreenSizeCoefficient " h" 175*ScreenSizeCoefficient, "Custom Sound")
    CurrentSoundText := SettingsGUI.Add("Text", "W" 210*ScreenSizeCoefficient " XP+5 YP+" 35*ScreenSizeCoefficient, "Selected File:")
    CurrentSoundText.SetFont("s" AdjustedSettingsFontSize/1.5)
    global CurrentSoundVar := SettingsGUI.Add("Text", "W" 210*ScreenSizeCoefficient " XP YP+" 20*ScreenSizeCoefficient, SoundValueTranslation(settings["Sound"]))
    CurrentSoundVar.SetFont("s" AdjustedSettingsFontSize/1.5)
    CurrentSoundText.Opt("+Center +0x200")
    CurrentSoundVar.Opt("+Center +0x200")
    Button_SetSound := SettingsGUI.Add("Button", "W" 210*ScreenSizeCoefficient " H" 30*ScreenSizeCoefficient " XP YP+" 40*ScreenSizeCoefficient, "Choose Custom Sound")
    Button_SetSound.SetFont("s" AdjustedSettingsFontSize/1.5)
    Button_SetSound.OnEvent("Click", OpenFileSelect)
    Button_ResetSound := SettingsGUI.Add("Button", "W" 210*ScreenSizeCoefficient " H" 30*ScreenSizeCoefficient " XP YP+" 35*ScreenSizeCoefficient, "Reset Sound to Default")
    Button_ResetSound.SetFont("s" AdjustedSettingsFontSize/1.5)
    Button_ResetSound.OnEvent("Click", ResetSound)
    SettingsGUI.Show
}

F3::CreateSettingsGUI()

; F4 hotkey to toggle dragging
F4:: {
    global IsDraggable
    IsDraggable := !IsDraggable ; Toggle the draggable state
    EnableDragging(IsDraggable) ; Enable or disable dragging based on the toggle
    if IsDraggable {
        ToolTip("Dragging Enabled")
    } else {
        ToolTip("Dragging Disabled")
    }
    Sleep(1000)
    ToolTip("") ; Hide the tooltip after a short delay
}

f:: {
    if (!settings["ToggleInstabreak"]) {
        Sleep(2100)

        ;Detain 1
        Timer(14)
        Sleep(100)
        
        ;Detain 2
        Timer(14)
        Sleep(222)

        ;Detain 3
        Timer(14)
        Sleep(965)

        ;Detain 4;
        Timer(13)
        Sleep(316)

        ;Cleanse 1

        ;Detain 5
        Timer(21)
        Sleep(30)

        ;Detain 6
        Timer(14)
        Sleep(1120)

        ;Detain 7
        Timer(13)
        Sleep(950)

        ;Cleanse 2

        ;Detain 8
        Timer(20)
        Sleep(150)

        ;Detain 9
        Timer(14)
        Sleep(100)

        ;Detain 10
        Timer(14)
        Sleep(850)

        ;Detain 11
        Timer(20)
        Sleep(100)

        ;Cleanse 3

        ;Detain 12
        Timer(14)
        Sleep(300)

        ;Detain 13
        Timer(14)
        Sleep(500)

        ;Detain 14
        Timer(20)

        ;Detain 15
        Timer(14)

        ;Detain 16
        Timer(14)
    } else {
        Sleep(1600) ; 1frame = 18,33s

        ;Detain 1
        Timer(5)
        Sleep(100)	
    
        ;Detain 2
        Timer(14)
        Sleep(100)
        
        ;Detain 3
        Timer(14)
        Sleep(222)
    
        ;Detain 4
        Timer(14)
        Sleep(965)
    
        ;Detain 5;
        Timer(13)
        Sleep(316)
    
        ;Cleanse 1
    
        ;Detain 6
        Timer(21)
        Sleep(30)
    
        ;Detain 7
        Timer(14)
        Sleep(1120)
    
        ;Detain 8
        Timer(13)
        Sleep(950)
    
        ;Cleanse 2
    
        ;Detain 9
        Timer(20)
        Sleep(150)
    
        ;Detain 10
        Timer(14)
        Sleep(150)
    
        ;Detain 11
        Timer(14)
        Sleep(850)
    
        ;Detain 12
        Timer(20)
        Sleep(100)
    
        ;Cleanse 3
    
        ;Detain 13
        Timer(14)
        Sleep(300)
    
        ;Detain 14
        Timer(14)
        Sleep(500)
    
        ;Detain 15
        Timer(20)
    
        ;Detain 16
        Timer(14)
    
        ;Detain 17
        Timer(14)
    }
}

^J::Reload
^K::ExitApp