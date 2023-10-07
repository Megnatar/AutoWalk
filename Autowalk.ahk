/*
    Autowalk v1.0.5.0 writen by Megnatar

    Everyone is free to use, add code and redistribute this script.
    But you MUST always credit ME Megnatar for creating the source!
    The source code for this script can be found on my Github repository:
    https://github.com/Megnatar/AutoWalk/tree/main
*/

#NoEnv
#SingleInstance force
#InstallKeybdHook
#KeyHistory 1024
ListLines off
SetBatchLines -1
SetTitleMatchMode 3
SetKeyDelay 5, 1
SetWorkingDir %A_ScriptDir%
sendmode Input
CoordMode, Mouse, screen

; Load variables
#Include .\Script\Vars.ahk

; Initialize script
#Include .\Script\Init.ahk

; Load the GUI
#Include .\Script\Gui.ahk

; Start listening for mouse events when it's over the gui.
OnMessage(Wm_MouseMove, "WM_Mouse")
OnMessage(Wm_LbuttonDown, "WM_Mouse")
OnMessage(Wm_DraggGui, "WM_Mouse")

; Load all labels, used by the gui.
#Include .\Script\GuiLables.ahk

; Save settings whenever the script closes.
OnExit("SaveSettings")
Return ; Done loading!

;_______________________________________ Game Specific Code _______________________________________

; When this file "UserCode.ahk" resides in the same folder as where the script is.
; Then the code in that file is used by this script when the game window is active.
; Read comment on function ButtonSingleDouble() for more instructions.
;
#IfWinExist ahk_group ClientGroup
#IfWinActive ahk_group ClientGroup
#Include *i UserCode.ahk
Return

;_______________________________________ Script Functions And Classes _______________________________________

class AutoWalk
{
    
    __New(sndkey, inpkey) {
    
        Static SendKey, InputKey
        
        if (SendKey)
            SendKey   := ""
            
        if (InputKey)
            InputKey   := ""
            
        this.SendKey  := sndKey
        this.InputKey := inpkey
    }
    
    
    Start() {
    
        KeyOut := This.Sendkey
        KeyIn := this.InputKey
        
        SendEvent {%KeyOut% Down}
        Hotkey, ~*Vk057, HotKeyAutoWalk, ON     ; Vk057 = w
        Hotkey, Vk01, HotKeyAutoWalk, ON        ; Vk01  = LButton
        Return 1
    }

    Stop() {
    
        Key := This.Sendkey
        
        SendEvent {%Key% Up}
        Hotkey, ~*Vk057, HotKeyAutoWalk, Off    ; Vk057 = w
        Hotkey, Vk01, HotKeyAutoWalk, Off       ; Vk01  = LButton
        Return 0
    }
}

; Creates the right click contextmenu in the listview.
GuiContextMenu(GuiHwnd, CtrlHwnd, EventInfo, IsRightClick, X, Y) {

    Global hLVItems, GameTitle
    Static LeftClick := 0
    
    LeftClick += 1
    
    ; Formats var hLVItems back to an integer. Only show the menu, when a leftclick was inside the listview.
    ; And ignore a second left click when the menu is still open.
    if (CtrlHwnd = Format("{1:i}", hLVItems) && leftclick = 1) {

        ; Get game title from the Selected column
        LV_GetText(GameTitle, EventInfo, 2)
        
        ; Strip all spaces from GameTitle check It's value.
        if (trim(GameTitle) = "Game") {
            
            ; Default title is the title of the loaded game.
            GameTitle := Title
        }
        
        ; Show the context menu in the list view.
        menu, LVMenu, add, Delete this game?, MenuActions
        menu, LVMenu, add, Change Title, MenuActions
        menu, LVMenu, add
        menu, LVMenu, add, Hide listview, MenuActions
        Menu, LVMenu, Show, %x%, %y%
        Menu, LVMenu, Delete
        
    }
    
    ; Set number of clicks back to none.
    LeftClick := 0
}

LoadIcons(IconLib) {

    Global
    ; If (IsObject(IconLib)) {}
    
    ; Create two ImageLists, so the ListView can display icons:
    ImageListID1 := IL_Create(10)
    ImageListID2 := IL_Create(10, 10, true)  ; A list of large icons to go with the small ones.

    ; Attach the ImageLists to the ListView, so icons can be loaded into the gui:
    LV_SetImageList(ImageListID1)
    LV_SetImageList(ImageListID2)
    
    ; Set the buffer size, required for the SHFILEINFO structure.
    sfi_size := A_PtrSize + 8 + (A_IsUnicode ? 680 : 340)
    VarSetCapacity(SHFILEINFO, sfi_size)


    Loop % IconLib.Length()
    {

        FilePath := IconLib[A_Index, 1]
        FileName := IconLib[A_Index, 2]

        ; Build a unique extension ID to avoid characters that are illegal in variable names,
        ; such as dashes. This unique ID method also performs better because finding an item
        ; in the array does not require search-loop.
        
        SplitPath, FilePath,,, FileExt  ; Get the file's extension.
        if FileExt in EXE,ICO,ANI,CUR
        {
            ExtID := FileExt  ; Special ID as a placeholder.
            IconNumber := 0   ; Flag it as not found so that these types can each have a unique icon.
        }
        else  ; Some other extension/file-type, so calculate its unique ID.
        {
            ExtID := 0  ; Initialize to handle extensions that are shorter than others.
            Loop 7      ; Limit the extension to 7 characters so that it fits in a 64-bit value.
            {
                StringMid, ExtChar, FileExt, A_Index, 1
                if not ExtChar  ; No more characters.
                    break
                ; Derive a Unique ID by assigning a different bit position to each character:
                ExtID := ExtID | (Asc(ExtChar) << (8 * (A_Index - 1)))
            }
            ; Check if this file extension already has an icon in the ImageLists. If it does,
            ; several calls can be avoided and loading performance is greatly improved,
            ; especially for a folder containing hundreds of files:
            
            IconNumber := IconArray%ExtID%
        }
        if not IconNumber  ; There is not yet any icon for this extension, so load it.
        {
            ; Get the high-quality small-icon associated with this file extension:
            if not DllCall("Shell32\SHGetFileInfo" . (A_IsUnicode ? "W":"A"), "Str", FilePath, "UInt", 0, "Ptr", &SHFILEINFO, "UInt", sfi_size, "UInt", 0x101)  ; 0x101 is SHGFI_ICON+SHGFI_SMALLICON
            {
                IconNumber := 9999999  ; Set it out of bounds to display a blank icon.
            }
            else ; Icon successfully loaded.
            {
                ; Extract the hIcon member from the structure:
                hIcon := NumGet(SHFILEINFO, 0)
                ; Add the HICON directly to the small-icon and large-icon lists.
                ; Below uses +1 to convert the returned index from zero-based to one-based:
                IconNumber := DllCall("ImageList_ReplaceIcon", "Ptr", ImageListID1, "Int", -1, "Ptr", hIcon) + 1
                DllCall("ImageList_ReplaceIcon", "Ptr", ImageListID2, "Int", -1, "Ptr", hIcon)
                ; Now that it's been copied into the ImageLists, the original should be destroyed:
                DllCall("DestroyIcon", "Ptr", hIcon)

                IconArray%ExtID% := IconNumber

            }
        }
        ; Create the new row in the ListView and assign it the icon number determined above:
        LV_Add("Icon" . IconNumber, , FileName)
    }
}

; Read ini file and create variables. Sections are supported.
; Referenced variables are not local to functions!
; Thus %VarRef% represents the name of some variable,
; that usually is declaired at the top of the script
iniRead(InputFile, LoadSection = 0) {

    if (LoadSection) {
    
        if (IsObject(LoadSection)) {    
        ; Load multiple sections from object
             for i, Name in LoadSection
             {
                Loop, parse, % FileOpen(InputFile, 0).read(), `n, `r
                {
                    if (InStr(A_Loopfield, Name)) {
                    
                        SectionName := StrReplace(A_Loopfield, "["), SectionName := StrReplace(SectionName, "]")
                        Continue
                        
                    }
                    if (SectionName) {
                        if (((InStr(A_LoopField, "[",, 1, 1)) = 1) | ((InStr(A_LoopField, "`;",, 1, 1)) = 1) | (!A_LoopField)) {
                        
                            if (((InStr(A_LoopField, "`;",, 1, 1)) = 1) | (!A_LoopField)) {
                            
                                Continue
                                
                            } else {
                            
                                SectionName := ""
                                break
                                
                            }
                        }
                        VarRef := SubStr(A_LoopField, 1, InStr(A_LoopField, "=")-1), %VarRef% := SubStr(A_LoopField, InStr(A_LoopField, "=")+1)
                    }
                }
            }
        }
        Else if (!IsObject(LoadSection)) {
        
            if ((InStr(LoadSection, " ")) > 1) {                                ; Load multiple sections
            
                Sections := []
                
                Loop, Parse, LoadSection, " ", A_Space
                    Sections[A_Index] := A_Loopfield
                    
                for i, Name in Sections
                {
                    Loop, parse, % FileOpen(InputFile, 0).read(), `n, `r
                    {
                        if (InStr(A_Loopfield, Name)) {
                        
                            SectionName := StrReplace(A_Loopfield, "["), SectionName := StrReplace(SectionName, "]")
                            Continue
                            
                        }
                        if (SectionName) {
                            if (((InStr(A_LoopField, "[",, 1, 1)) = 1) | ((InStr(A_LoopField, "`;",, 1, 1)) = 1) | (!A_LoopField)) {
                            
                                if (((InStr(A_LoopField, "`;",, 1, 1)) = 1) | (!A_LoopField)) {
                                
                                    Continue
                                    
                                } else {
                                    SectionName := ""
                                    break
                                }
                            }
                            VarRef := SubStr(A_LoopField, 1, InStr(A_LoopField, "=")-1), %VarRef% := SubStr(A_LoopField, InStr(A_LoopField, "=")+1)
                        }
                    }
                }
            } Else {                                                        ; Load single section
                Loop, parse, % FileOpen(InputFile, 0).read(), `n, `r
                {
                    if (InStr(A_Loopfield, LoadSection)) {
                    
                        SectionName := StrReplace(A_Loopfield, "["), SectionName := StrReplace(SectionName, "]")
                        Continue
                        
                    }
                    If (SectionName) {
                    
                        if ((InStr(A_LoopField, "[",, 1, 1)) = 1)
                            Break
                        
                        VarRef := SubStr(A_LoopField, 1, InStr(A_LoopField, "=")-1), %VarRef% := SubStr(A_LoopField, InStr(A_LoopField, "=")+1)
                    }
                }
            }
        }
    }
    Else if (!LoadSection) {
    ; Load all variables from ini
        Loop, parse, % FileOpen(InputFile, 0).read(), `n, `r
        {
            if (((InStr(A_LoopField, "[",, 1, 1)) = 1) | ((InStr(A_LoopField, "`;",, 1, 1)) = 1) | (!A_LoopField))
                Continue
                
            ; Save only the first word in A_LoopField to VarRef. This word is a variable name.
            VarRef := SubStr(A_LoopField, 1, InStr(A_LoopField, "=")-1)
            
            ; Give the variable it's value.
            %VarRef% := SubStr(A_LoopField, InStr(A_LoopField, "=")+1)
        }
    }
    Return
}

; KeyWait as a function for more flexible usage. Returns the key it waited for or ErrorLevel.
; When no parameters are used, keywait will use the value in A_ThisHotkey as the key to wait for.
KeyWait(Key = 0, Options = 0, ErrLvL = 0) {

    keywait, % ThisKey := Key ? Key : RegExReplace(A_ThisHotkey, "[~\*\$]"), % Options
    Return ErrLvL = 1 ? ErrorLevel : ThisKey
    
}

; Returns the last hotkey used with all modifiers removed from it.
ThisHotKey() {

    Return RegExReplace(A_ThisHotkey, "[~\*\$]")
    
}

/*
    GuiControl as a function for more flexible usage. Parameter ControlID can be a array.
    For example, if you want to use the GuiControl command 3 times in a row.
    Then the array should look something like:
    ControlID := [[SubCommand, ControlID, Value], [SubCommand, ControlID], [ , ControlID, Value]]

    You can also insert objects directly on the parameter for ControlID.
    GuiControl([[SubCommand, ControlID, Value], [SubCommand, ControlID], [ , ControlID, Value]])

    Command options. See ahk manual for details.

    .(Blank): Puts new contents into the control.
    .Text: Changes the text/caption of the control.
    .Move: Moves and/or resizes the control.
    .MoveDraw: Moves and/or resizes the control and repaints the region occupied by it.
    .Focus: Sets keyboard focus to the control.
    .Disable: Disables (grays out) the control.
    .Enable: Enables the control.
    .Hide: Hides the control.
    .Show: Shows the control.
    .Delete: Not yet implemented.
    .Choose: Selects the specified item number in a multi-item control.
    .ChooseString: Selects a item in a multi-item control whose leading part matches a string.
    .Font: Changes the control's font typeface, size, color, and style.
    .Options: Add or remove various control-specific or general options and styles.
*/
GuiControl(ControlID, SubCommand = 0, Value = 0) {

    If (IsObject(ControlID)) {
    
        Loop % ControlID.Length() {
        
            GuiControl % ControlID[A_index][1], % ControlID[A_index][2], % ControlID[A_index][3]
            
        }
    } else {
    
        GuiControl % SubCommand, % ControlID, % Value
        
    }
    Return ErrorLevel
}

; Keep track of mouse movement and left mouse button state inside the GUI.
WM_Mouse(wParam, lParam, msg, hWnd) {
    Static ClsNNPrevious, ClsNNCurrent, _TT, CurrControl, PrevControl
    ListLines off   ; Even when globaly enabled. Best to set it off here.

    ; ClsNNPrevious and ClsNNCurrent will hold the same value while the mouse moves inside a control.
    ClsNNPrevious := ClsNNCurrent
    MouseGetPos, , , , ClsNNCurrent
    ControlBelowMouse := ClsNNCurrent

    ; When the mouse moved from one control to the other. ClsNNPrevious and ClsNNCurrent, both hold a different value.
    if (ClsNNCurrent != ClsNNPrevious)
        ControlOldBelowMouse := ClsNNPrevious

    if (msg = WM_MOUSEMOVE) {
    
        If (SpyGlass = 1) {
        
            MouseGetPos, now_x, now_y
            now_x -= 75
            now_y -= 75
            WinMove, Magnifier, , %now_x%, %now_y%
            ToolTip % now_x "  " now_y
            
        }
        if (!TipsOff) {
        
            CurrControl := A_GuiControl

            if ((ClsNNPrevious != ClsNNCurrent) & (!InStr(CurrControl, " "))) {
            
                ToolTip  ; Turn off any previous tooltip.
                SetTimer, DisplayToolTip, 750
                PrevControl := CurrControl
                
            }
            return

            DisplayToolTip:
            SetTimer, DisplayToolTip, Off
            ToolTip % %CurrControl%_TT  ; The leading percent sign tell it to use an expression.
            SetTimer, RemoveToolTip, 5000
            return

            RemoveToolTip:
            SetTimer, RemoveToolTip, Off
            ToolTip
            return
        }
    }
    
    if (msg = Wm_LbuttonDown) {
    
        SetTimer, RemoveToolTip, Off
        
        ; When some control under the mouse is a Edit control and the script is not already getting a key.
        If ((InputActive = 0) & (InputActive := InStr(ControlBelowMouse, "Edit"))) {
        
            GuiControlGet, IsControlOn, Enabled, %ControlBelowMouse%

            ; Ignore the windows used by autohotkey for ListVars, ListLines and so on.
            If (WinGetActiveTitle() != "AutoWalk")
                Return

            ; And when this control is not disabled.
            If (IsControlOn = 1) {

                ; store it's text and give the control input focus (actually it's the other way around, hehe).
                ControlFocus, %ControlBelowMouse%
                ControlGetText, ctrlTxt, %ControlBelowMouse%

                ; Briefly enable this control to call function EditGetKey when it recieves some input.
                GuiControl([["+gEditGetKey", ControlBelowMouse], [, ControlBelowMouse], ["-gEditGetKey", ControlBelowMouse]])
                
            } else {
            
                InputActive := 0
                
            }
        }
        if ((GetKeyState("LButton", "P")) & (!A_GuiControl) & (WinActive("A") != hClipMsg)) {
        
            PostMessage, Wm_DraggGui
            
        }
        Return
    }

    if (msg = Wm_DraggGui) {
    
        if ((GetKeyState("LButton", "P")) & (!A_GuiControl)) {
        
            FadeInOut(hScriptGui, 1)
            PostMessage, WM_NCLBUTTONDOWN, 2
            KeyWait("LButton")
            FadeInOut(hScriptGui)
        
        }
        Return
    }
}

; Fade transparency out or in while dragging the Gui.
FadeInOut(hWnd, dragg = 0) {
    static Transparency := 255, TransparencyOff := 255, WaitNextTick := 0, IncrementValue := 25, MlsNextLoop := 05, TransparencyLow := 100
    
    if (dragg = 1) {
        Loop {
            If (A_TickCount >= WaitNextTick) {
                WaitNextTick := A_TickCount+MlsNextLoop
                
                WinSet, Transparent, % Transparency -= IncrementValue, ahk_id %hWnd%
                If (Transparency <= TransparencyLow)
                    break
            }
        }
    } Else if (dragg = 0) {
        Loop {
            If (A_TickCount >= WaitNextTick) {
                WaitNextTick := A_TickCount+MlsNextLoop
                
                WinSet, Transparent, % Transparency += IncrementValue, ahk_id %hWnd%
                If (Transparency >= TransparencyOff) {
                    WinSet, Transparent, Off, ahk_id %hWnd%
                    break
                }
            }
        }
    }
    return
}

WinGetActiveTitle() {

    WinGetActiveTitle OutputVar
    Return OutputVar
    
}

; Write back the name of any keyboard, mouse or joystick button to a edit control.
EditGetKey() {

    static InputKeys := ["LButton", "RButton", "MButton", "XButton1", "XButton2", "Numpad0", "Numpad1", "Numpad2", "Numpad3", "Numpad4", "Numpad5", "Numpad6", "Numpad7", "Numpad8", "Numpad9","Numpad10","NumpadEnter", "NumpadAdd", "NumpadSub","NumpadMult", "NumpadDev", "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12", "Left", "Right", "Up", "Down", "Home","End", "PgUp", "PgDn", "Del", "Ins", "Capslock", "Numlock", "PrintScreen", "Pause", "LControl", "RControl", "LAlt", "RAlt", "LShift","RShift", "LWin", "RWin", "AppsKey", "BackSpace", "space", "Tab", "Esc", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N","O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ",", ".", "/", "[", "]", "\", "'", ";", "` ","Joy1", "Joy2", "Joy3", "Joy4", "Joy5", "Joy6", "Joy7", "Joy8", "Joy9", "Joy10", "Joy11", "Joy12", "Joy13", "Joy14", "Joy15", "Joy16", "Joy17","Joy18", "Joy19", "Joy20", "Joy21", "Joy22", "Joy23", "Joy24", "Joy25", "Joy26", "Joy27", "Joy28", "Joy29", "Joy30","Joy31", "Joy32"]

    KeyWait("LButton")

    ; Prevent a right click from showing the context menu.
    Hotkey, IfWinActive, AutoWalk
    Hotkey, Vk02 Up, RbttnUp, On     ; Vk02 = RButton

    ; Loop untill the user pressed some button or as long as the mouse is over some edit box.
    Critical
    loop {
        ; Getting user input from array Inputkeys.
        For k, ThisKey in InputKeys {
            if (GetKeyState(ThisKey, "P")) {
                GuiControl(ControlBelowMouse, "", ThisKey)
                ExitLoop := KeyWait(ThisKey)
                Break
            }
            ; When ControlBelowMouse does not contain the word "Edit". Then the mouse moved away from the control.
            If (!InStr(ControlBelowMouse, "Edit") & InStr(ControlOldBelowMouse, "Edit")) {
                ExitLoop := 1
                GuiControl(ControlOldBelowMouse, "", ctrlTxt)
                ControlFocus, %ControlBelowMouse%
                Break
            }
        }
        If (ExitLoop)
            break
    }
    Critical Off
    ControlFocus, Button2
    GUI, submit, nohide

    ; Save new values to Settings.ini if the For loop didn't break when the mouse moved outside the control.
    If (ExitLoop != 1)
        IniWrite, %ThisKey%, %ConfigFile%, Settings, %A_GuiControl%

    RbttnUp:
        Hotkey, IfWinExist, AutoWalk
        Hotkey, Vk02 Up, RbttnUp, Off

    InputActive := 0
    Return
}

; Send some key on a sinlge or double press of a button.
; The hotkey is optional and when ThisHotKey is empty Keywait() will return the last hokey used.
; This function can be used with the UserCode.ahk file e.g.:
; Below code would send A when F is pressed once. And B when F is pressed twice
; F::
;   ButtonSingleDouble("A", "B")
; Return
;
; And this will send B when you double click the right mouse button
; ~RButton::
;   ButtonSingleDouble("", "B")
; Return
;
ButtonSingleDouble(KeySingle, KeyDouble, ThisHotKey = 0, WaitRelease = 0) {
    if (WaitRelease) {
        Send {%KeySingle% Down}
        A_hotKey := ThisHotKey ? keywait(ThisHotKey) : keywait()
        Send {%KeySingle% Up}

        if (keywait(A_hotKey, "D T0.1", 1) = 0) {
            Send {%KeyDouble% Down}
            KeyWait(A_hotKey)
            Send {%KeyDouble% Up}
        }
    } Else if (!WaitRelease) {
        A_hotKey := ThisHotKey ? keywait(ThisHotKey) : keywait()

        if (keywait(A_hotKey, "D T0.1", 1) = 0) {
            Send {%KeyDouble% Down}{%KeyDouble% Up}
        } else {
            Send {%KeySingle% Down}{%KeySingle% Up}
        }
    }
    Return
}

; Automaticly turn the ingame camera to follow the player when some key is down.
AutoTurnCamera(KeyDown, RotateL, RotateR, VirtualKey = 0, DownPeriod = 350, DeadZone = 65) {
    Static Rad := 182.5 / 3.1415926

    ; The width and hight of the client gui might change in between calls, so getting them here.
    WinGetPos, , ,gW, gH, A

    ; Check mouse position and turns the camera when the mouse moved outside a deadszone while the key in KeyDown has status Down.
    ; By default the physical key state is monitored. Set parameter VirtualKey to 1 to check the logical key state. Logical is when
    ; a key is send Down by the send command or in some other way.
    ;
    While(GetKeyState(KeyDown, (!VirtualKey ? "P" : ""))) {
        MouseGetPos, mX, mY

        ; Calculate cursor position, where the vertical/horizontal centre of the display are seen as zero. Both the left and right side
        ; of the display are seen as positive (Abs). A triangle (ATan) of 70 degrees (35*2) is created from the very centre to the top/bottom.
        ; These triangles will be the dead zone, where the camera does not turn.
        ;
        if (((((X := mX - gW/2) * mX) + ((Y := gH/2 - mY) * mY) < 10000) | (Y > 0)) & ((Abs(ATan(X/Y)) * Rad) < DeadZone)) {
            continue
        }

        ; Turn the ingame camera left or right when the mouse moved outside the deadzone.
        ; I advice to make the value in DownPeriod not greater then the 50ms sleep. If you do,
        ; then also increase the sleep period to somthing greater then the down perdiod.
        ; This will result in a smoother turning of the camera.
        ;
        if (X < 0) {
            Send {%RotateL% Down}
            Sleep, %DownPeriod%
            Send {%RotateL% Up}
        } else {
            Send {%RotateR% Down}
            Sleep, %DownPeriod%
            Send {%RotateR% Up}
        }
        sleep 50
    }
    Return
}

PotGetCoords(SendKeys, CoPot1, CoPot2 := "" ) {
    Global Pot1X, Pot1Y, Pot2X, Pot2Y, Pot2Color, Pot1Color, Pot1Range

    Vars := [["lX1", "ly1", "rX1", "rY1"], ["lX2", "ly2", "rX2", "rY2"]]

    Loop, Parse, SendKeys, " ", A_Space
    {
        if (A_Index = 1) {
            Pot1Range := A_LoopField
            Continue
        }
        n := A_Index-1, Key%n% := A_LoopField
    }
    Loop, Parse, CoPot1, " ", A_Space
    {
        if (A_index = 5) {
            Procent1 := A_loopField
            Continue
        }
        v1 := Vars[1][A_Index], %v1% := A_loopfield
    }
    Loop, Parse, CoPot2, " ", A_Space
    {
        if (A_index = 5) {
            Procent2 := A_loopField
            Continue
        }
        v2 := Vars[2][A_Index], %v2% := A_loopfield
    }

    ; For both pots, calculate where the pixel is on screen at the user specified percentage. And get it's color.
    loop 2
    {
        if ((rX%A_index% - lX%A_index%) > (rY%A_index% - lY%A_index%)) {
            Pot%A_index%X := Round(((lX%A_index% - rX%A_index%) / 100) * Procent%A_Index%) + rX%A_Index%, Pot%A_index%Y := lY%A_index%
        } else {
            Pot%A_index%X := lX%A_index%, Pot%A_index%Y := Round(((rY%A_index% - lY%A_index%) / 100) * Procent%A_index%) + lY%A_index%
        }
        PixelGetColor, Pot%A_index%Color, Pot%A_index%X, Pot%A_index%Y, Slow RGB
    }
    SetTimer, TriggerPot, 500
    return
}

Random(Min, Max) {
    Random, N, % Min , % Max
    Return N
}

; Reload() and below that exit(), Exit or close the script without calling function SaveSettings() first.
Reload(NoSave = 0) {

    if (NoSave = 1) {
        OnExit("SaveSettings", 0)
    }

    If (A_IsCompiled) {
        Run "%A_ScriptFullPath%" /restart
    } Else {
        Run "%A_AhkPath%" /restart "%A_ScriptFullPath%"
    }
    ExitApp()
}

ExitApp() {
    OnExit("SaveSettings", 0)
    ExitApp
}

; This is called right before the script terminates. It saves the position of the GUI and copies
; all current variables from the settings.ini to \GameProfiles\GamesConfig.ini.
; GamesConfig.ini contains all variables from the previous used games.
;
SaveSettings() {
    WinGetPos, Gui_X, Gui_Y, ,, AutoWalk

     ; Remember the position of the script GUI when it's not somewhere outside the display.
    if ((Gui_X > -1) & (Gui_Y > -1)) {
        IniWrite, %Gui_X%, %ConfigFile%, Settings, Gui_X
        IniWrite, %Gui_Y%, %ConfigFile%, Settings, Gui_Y
    }


    ; When the window title is the title of the game window.
    if ((Title) && (Title != "Ready to start you're game")) {
    
        If (!FileExist(Profiles)) {
        
            FileCreateDir, GameProfiles
            FileAppend,, %Profiles%
            
        }
        ; Save all values from Settings.ini to the Profiles.ini file
        Loop, parse, % FileOpen(ConfigFile, 0).read(), `n, `r
        {
        
            if (InStr(A_Loopfield, "[")) {
            
                SectionName := StrReplace(A_Loopfield, "["), SectionName := StrReplace(SectionName, "]")
                IniDelete, %Profiles%, %Title%
                FileAppend, % "[" Title "]", %Profiles%
                
            }
            
            Else If (SectionName && A_LoopField) {
            
                VarRef := SubStr(A_LoopField, 1, InStr(A_LoopField, "=")-1)
                IniWrite, % %VarRef%, %Profiles%, %Title%, %VarRef%
                
            }
        }
    }
}

OnMsgBox() {

    DetectHiddenWindows, On
    Process, Exist
    
    If (WinExist("ahk_class #32770 ahk_pid " . ErrorLevel)) {
    
        hIcon := LoadPicture("shell32.dll", "w32 Icon270", _)
        SendMessage 0x172, 1, %hIcon%, Static1 ; STM_SETIMAGE
        
    }
}

/*

; Not mine, but borrowed from the ahk manual.
SystemCursor(OnOff=1)   ; INIT = "I","Init"; OFF = 0,"Off"; TOGGLE = -1,"T","Toggle"; ON = others
{
    static AndMask, XorMask, $, h_cursor
        , c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13 ; system cursors
        , b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13    ; blank cursors
        , h1,h2,h3,h4,h5,h6,h7,h8,h9,h10,h11,h12,h13    ; handles of default cursors
    if (OnOff = "Init" or OnOff = "I" or $ = "")        ; init when requested or at first call
    {
        $ := "h"                                       ; active default cursors
        VarSetCapacity( h_cursor,4444, 1 )
        VarSetCapacity( AndMask, 32*4, 0xFF )
        VarSetCapacity( XorMask, 32*4, 0 )
        system_cursors := "32512,32513,32514,32515,32516,32642,32643,32644,32645,32646,32648,32649,32650"
        StringSplit c, system_cursors, `,
        Loop %c0%
        {
            h_cursor   := DllCall( "LoadCursor", "Ptr",0, "Ptr",c%A_Index% )
            h%A_Index% := DllCall( "CopyImage", "Ptr",h_cursor, "UInt",2, "Int",0, "Int",0, "UInt",0 )
            b%A_Index% := DllCall( "CreateCursor", "Ptr",0, "Int",0, "Int",0
                , "Int",32, "Int",32, "Ptr",&AndMask, "Ptr",&XorMask )
        }
    }
    if (OnOff = 0 or OnOff = "Off" or $ = "h" and (OnOff < 0 or OnOff = "Toggle" or OnOff = "T"))
        $ := "b"  ; use blank cursors
    else
        $ := "h"  ; use the saved cursors

    Loop %c0%
    {
        h_cursor := DllCall( "CopyImage", "Ptr",%$%%A_Index%, "UInt",2, "Int",0, "Int",0, "UInt",0 )
        DllCall( "SetSystemCursor", "Ptr",h_cursor, "UInt",c%A_Index% )
    }
}



SpyGlass:
    SpyGlass := 1
    OnMessage(Wm_LbuttonDown, ""), OnMessage(Wm_DraggGui, "")
    CoordMode, Mouse, screen
    zoom = 2
    Ws_Caption := 0xC00000
    Ws_Border := 0x800000

    MouseGetPos, X, Y, hWndWinBelowCur

    Gui 2:+AlwaysOnTop +ToolWindow +OwnDialogs -0xC00000 -0x800000 +0x40000000 +E0x80000 +HwndhWndScript
    Gui 2:Show, w250 h250 x%X% y%Y%, Magnifier

    OnMessage(Wm_Mousemove, "Wm_Mousemove")
    WinGetClass, ClientGuiClass, ahk_id %hWndScript%
    WinSet, Region, 0-0 W150 H150 E, ahk_class %ClientGuiClass%
    WinSet, Transparent , 254, Magnifier

    SetTimer, MoveWin, 10

    ;retrieve the unique ID number (HWND/handle) of that window
    WinGet, hWndWinBelowCur, id
    hdc_frame := DllCall("GetDC", UInt, hWndScript)
    hdd_frame := DllCall("GetDC", UInt, hWndWinBelowCur)
    hdc_buffer := DllCall("gdi32.dll\CreateCompatibleDC", UInt,  hdc_frame)  ; buffer
    hbm_buffer := DllCall("gdi32.dll\CreateCompatibleBitmap", UInt,hdc_frame, Int,A_ScreenWidth, Int,A_ScreenHeight)
    SystemCursor("Toggle")
    Gosub, Repaint
return

Repaint:
    if (GetKeyState("LButton", "D")) {
        SetTimer, Repaint, Off
        OnMessage(Wm_LbuttonDown, "WM_Mouse"), OnMessage(Wm_DraggGui, "WM_Mouse")
    }

   MouseGetPos, X, Y, hWndWinBelowCur             ;  position of mouse
   WinGetPos, wx, wy, ww, wh, Magnifier
   wh2 := wh

   DllCall( "gdi32.dll\SetStretchBltMode", "uint", hdc_frame, "int", 0 )  ; No Antializing

   DllCall("gdi32.dll\StretchBlt", UInt, hdc_frame, Int, 0, Int, 0, Int, ww, Int, wh, UInt, hdd_frame, Int, X-(ww / 2 / zoom), Int, Y-(wh/2/zoom), Int, ww/zoom, Int, wh2/zoom ,UInt,0xCC0020) ; SRCCOPY

   SetTimer, Repaint , 0
Return

MoveWin:
MouseGetPos, now_x, now_y`
now_x -= 75
now_y -= 75
WinMove, Magnifier, , %now_x%, %now_y%
Return ;*[Autowalk]


!+WheelUp::			; Alt+Shift+WheelUp to zoom in
  If zoom != 16
      zoom *= 2
Return

!+WheelDown::		; Alt+Shift+WheelUp to zoom out
  If zoom != 2
      zoom /= 2
Return

!x::
    SystemCursor("On")
    DllCall("gdi32.dll\DeleteObject", UInt,hbm_buffer)
    DllCall("gdi32.dll\DeleteDC", UInt,hdc_frame )
    DllCall("gdi32.dll\DeleteDC", UInt,hdd_frame )
    DllCall("gdi32.dll\DeleteDC", UInt,hdc_buffer)
    Gui 2:Destroy
Return

*/
