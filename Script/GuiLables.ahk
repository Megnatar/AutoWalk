;_______________________________________ Script Lables _______________________________________

MenuActions:
    ; Check or uncheks menuitems. Then toggles the value for the variable that is accosiated
    ; with the menuitem to the opesite. Saves or remove the variable to/from ini file.
    If (A_ThisMenu = "GameMenu") {
    
        If (A_ThisMenuItem = "Start Game") {
        
            Gosub, ButtonStartGame
            
        } else if (A_ThisMenuItem = "Quit Game") {
        
            WinClose, ahk_class %ClientGuiClass%
            Reload()
            
        } else if (A_ThisMenuItem = "Add New Game") {
        
            Gosub ButtonBrowse
        }
        
    }
    Else If (A_ThisMenu = "OptionsMenu") {
    
        For MenuItemTxt, VariableName in MenuItems
        {
            If (A_ThisMenuItem = MenuItemTxt) {
                Menu %A_ThisMenu%, ToggleCheck, %MenuItemTxt%

                if (%VariableName% := %VariableName% ? 0 : 1) {
                
                    IniWrite, % %VariableName%, %ConfigFile%, Settings, %VariableName%
                    
                } else {
                
                    IniDelete, %ConfigFile%, Settings, %VariableName%
                }
            }
        }
        
        If (A_ThisMenuItem = "Toggle Admin") {
        
            Admin ? Reload() : ExitApp()
            
        } Else If (A_ThisMenuItem = "Toggle OnTop") {
        
            Gui % (OnTop ? "+" : "-") "AlwaysOnTop"
            
        } Else If (A_ThisMenuItem = "Show Game List") {
            
            if (ShowGameList) {
                
                GuiControl([["Show", "GBGameList"], ["Show", "ListviewActions"], ["", "ShowGameList", 1]])
                WinMove, AutoWalk,,,, 963
                IniWrite, %ShowGameList%, %ConfigFile%, Settings, ShowGameList
                
            } else {

                GuiControl([["Hide", "GBGameList"], ["Hide", "ListviewActions"], ["", "ShowGameList", 0]])
                WinMove, AutoWalk,,,, 573
                IniDelete, %ConfigFile%, Settings, ShowGameList
            }
        }
    }
    Else If (A_ThisMenu = "ScriptMenu") {
    
        If (A_ThisMenuItem = "Reset Script") {
        
            SaveSettings()
            
            If (FileExist(A_ScriptDir "\UserCode.ahk")) {
            
                FileCopy, % A_ScriptDir "\UserCode.ahk", % UserCodeFiles "\" Title ".ahk", 1
                FileDelete % A_ScriptDir "\UserCode.ahk"
            }
            
            FileDelete %ConfigFile%
            Admin ? Reload() : ExitApp()
            
        }
        Else if (A_ThisMenuItem = "Reload Script") {
        
            Reload
            
        } Else If (A_ThisMenuItem = "Add/Edit Code") {
        
            if (!DefaultEditor) {
            
                RegRead, DefaultEditor, HKEY_CLASSES_ROOT\AutoHotkeyScript\Shell\Edit\Command
                Clipboard := DefaultEditor
                
                if (ErrorLevel) {
                
                    MsgBox, 0x24, Missing default editor, % "It seems you're machine hase no default editor installed.`nDo you wish to select one?`n`nYes:`nFile association for *.ahk files will be configured for you're chosen tool.`n`nNo:`nThe script will use notepad to edit *.ahk files."

                    IfMsgBox Yes, {
                    
                        FileSelectFile DefaultEditor, 2,, Select your editor, Programs (*.exe, *.ahk)
                        
                        if ErrorLevel
                            return
                            
                        RegWrite REG_SZ, HKCR, AutoHotkeyScript\Shell\Edit\Command,, "%DefaultEditor%" "`%1"
                    }
                    Else IfMsgBox No, {
                    
                        RegWrite REG_SZ, HKCR, AutoHotkeyScript\Shell\Edit\Command,, "Notepad.exe" "`%1"
                    }
                }
                Else if (!ErrorLevel) {
                
                    MsgBox, 0x23, Use default editor, % "You are using " StrReplace(SubStr(DefaultEditor,InStr(DefaultEditor,"\",,0,1)+1), """ ""`%1""") " as you're default editor.`nDo you want the script to also use it for editing?`n`nNo to select a different editor."
                    
                    IfMsgBox Yes, {
                    
                        IniWrite, % StrReplace(DefaultEditor, """" `%1 """"), %ConfigFile%, Settings, DefaultEditor
                        
                    } else IfMsgBox No, {
                    
                        FileSelectFile DefaultEditor, 2,, Select your editor, Programs (*.exe, *.ahk)
                        
                        if ErrorLevel
                            return
                            
                        RegWrite REG_SZ, HKCR, AutoHotkeyScript\Shell\Edit\Command,, "%DefaultEditor%" "`%1"
                        
                    } Else IfMsgBox Cancel, {
                        Return
                    }
                }
                FileAppend, ExitApp`nreturn`n, %A_ScriptDir%\UserCode.ahk
            }
            Run %DefaultEditor% UserCode.ahk
            
        }
        Else if (A_ThisMenuItem = "Spy Glass") {

            if (OnTop)
                Gui -AlwaysOnTop

            OnMessage(0x44, "OnMsgBox")
            MsgBox 0x80, ToDo: ?, Not Implemented yet, 4
            OnMessage(0x44, "")

            if (OnTop)
                Gui +AlwaysOnTop
                
        }
        Else if (A_ThisMenuItem = "AutoPot") {
        
			Gui 1:+Disabled
            Gui AutoPot:+Owner1 +LastFound +AlwaysOnTop +ToolWindow hwndHAutoPot
            Gui AutoPot:Add, GroupBox, x8 y0 w353 h156
            Gui AutoPot:Add, CheckBox, x24 y24 w79 h23, Pot1
            Gui AutoPot:Add, CheckBox, x192 y24 w72 h23, Pot2
            Gui AutoPot:Add, Edit, x24 y120 w60 h21
            Gui AutoPot:Add, Edit, x152 y120 w60 h21
            Gui AutoPot:Add, Edit, x280 y120 w60 h21
            Gui AutoPot:Add, Edit, x216 y120 w60 h21
            Gui AutoPot:Add, Edit, x88 y120 w60 h21
            Gui AutoPot:Add, Slider, x24 y72 w120 h24, 50
            Gui AutoPot:Add, Slider, x192 y72 w120 h24, 50
            Gui AutoPot:Add, GroupBox, x16 y104 w337 h44 +Center, Keys
            Gui AutoPot:Add, GroupBox, x16 y8 w154 h99
            Gui AutoPot:Add, Text, x24 y48 w121 h20 +0x200, Trigger pot1 on `%
            Gui AutoPot:Add, Text, x192 y48 w121 h20 +0x200, Trigger pot2 on `%
            Gui AutoPot:Add, GroupBox, x184 y8 w168 h98
            Gui AutoPot:Show, w367 h161, AutoPot
            Return

            AutoPotGuiClose:
            AutoPotGuiEscape:
            Gui AutoPot:destroy
            Gui 1:-Disabled
            GUI, Submit, Nohide
            WinActivate, ahk_id %hScriptGui%
            Return
        }
    ; The list View menu.
    }
    Else If (A_ThisMenu = "LvMenu") {
    
        ; Action to take when the delete game menu item clicked.
        if (A_ThisMenuItem = "Delete this game?") {
                
                ; Loop throught the ini file.
                Loop, parse, % FileOpen(Profiles, 0).read(), `n, `r
                {
                    ; Sections in a ini start with the [ character. So if a section is found!
                    if ((InStr(A_LoopField, "[",, 1, 1)) = 1) {

                        ; Strip square brackets from the section name. Which also is the window title.
                        SectionName := StrReplace(A_Loopfield, "["), SectionName := StrReplace(SectionName, "]")
                        
                        ; When global variable GameTitle equels the name of the current section in the loop.
                        if (GameTitle = SectionName) {
                        
                            ; Confirm delete.
                            MsgBox, 0x24, Delete game., % "Really?`n`nDelete this game:`n"  GameTitle ""
                            IfMsgBox Yes
                            {
                                IniDelete, % Profiles, % SectionName
                                
                            } else {
                            
                                Return
                            }
                        }
                    }
                }
                ; Reload the script.
                Reload()
        
        ; Change the name in the list view.
        }
        Else if (A_ThisMenuItem = "Change Title") {
        
            InputBox NewTitle, Change Title, Enter a new title below.,,,132,,,,, %GameTitle%
            ;MsgBox,,, % NewTitle
        
        ; Hide the list view.
        }
        Else if (A_ThisMenuItem = "Hide listview") {
        
            Gosub ShowGameList
        }
    }
Return

ListviewActions:
    Loop {
        if (!(RowNumber := LV_GetNext(RowNumber)))
            break
            
        LV_GetText(GameTitle, RowNumber, 2)
        
    }
    
    if (!GameTitle)
        Return

    Gui -AlwaysOnTop
    if (A_GuiEvent == "DoubleClick") {
    
        MsgBox,0x24, Load new settings, % "Do you want to load the settings for this game:`n " GameTitle ""
        IfMsgBox Yes
        {
            If (FileExist(ConfigFile)) {
            
                FileDelete %ConfigFile%
            }
            
            If (FileExist(A_ScriptDir "\UserCode.ahk")) {
            
                FileCopy, % A_ScriptDir "\UserCode.ahk", % UserCodeFiles "\" Title ".ahk", 1
                FileDelete % A_ScriptDir "\UserCode.ahk"
            }
            
            If (FileExist(Profiles)) {
            
                Loop, parse, % FileOpen(Profiles, 0).read(), `n, `r
                {
                    if ((InStr(A_LoopField, "[",, 1, 1)) = 1) {
                    
                        SectionName := StrReplace(A_Loopfield, "["), SectionName := StrReplace(SectionName, "]")

                    } Else if (GameTitle = SectionName) {
                    
                        VarRef := SubStr(A_LoopField, 1, InStr(A_LoopField, "=")-1), %VarRef% := SubStr(A_LoopField, InStr(A_LoopField, "=")+1)
                        
                        if (%VarRef%)
                            IniWrite, % %VarRef%, %ConfigFile%, Settings, %VarRef%
                    }
                }
                If (FileExist(UserCodeFiles "\" GameTitle ".ahk")) {
                
                    FileCopy, % UserCodeFiles "\" GameTitle ".ahk", % A_ScriptDir "\UserCode.ahk", 1
                    
                }
                Reload()
            }
        }
    }
    Gui % (OnTop ? "+" : "-") "AlwaysOnTop"
return

GuiDropFiles:
    Loop, parse, A_GuiEvent, `n, `r
        FullPath := A_LoopField, Path := SubStr(A_LoopField, 1, InStr(A_LoopField, "\", ,-1)-1), ExeFile := SubStr(A_LoopField, InStr(A_LoopField, "\", ,-1)+1)
    
    IniWrite % Admin := 1, %ConfigFile%, Settings, Admin
    IniWrite % TipsOff := 1, %ConfigFile%, Settings, TipsOff
    IniWrite % FullPath := Trim(Path) "\" Trim(ExeFile), %ConfigFile%, Settings, FullPath
    IniWrite %Path%, %ConfigFile%, Settings, Path
    IniWrite %ExeFile%, %ConfigFile%, Settings, ExeFile
    IniWrite % Title := "Ready to start you're game", %ConfigFile%, Settings, Title
    IniWrite % OnTop := 0, %ConfigFile%, Settings, OnTop
    
    Reload()
Return

ButtonBrowse:
    If ((A_ThisLabel = "ButtonBrowse") | (A_ThisMenuItem = "Add New Game")) {
    
        FileSelectFile, FullPath, M3, , ,*.exe
        
        Loop, parse, % FullPath, `n, `r
            A_Index <= 1 ? Path := A_LoopField : ExeFile := A_LoopField
            
        if (ErrorLevel)
            Exit
    }

    FileGetSize, fileSize, %FullPath%, K
    
    if ((FileSize < 1024) & (FileSize != ""))
        MsgBox,,FileSize: %FileSize% KB, % "The size of you're file is less then 1MB`n`nAre you sure this is the real exe and not a shortcut`nto a ecxecutable some folders below`n`nFile size: " FileSize "KB"

    If (FileExist(ConfigFile))
        FileDelete %ConfigFile%

    IniWrite % Admin := 1, %ConfigFile%, Settings, Admin
    IniWrite % TipsOff := 1, %ConfigFile%, Settings, TipsOff
    IniWrite % FullPath := Trim(Path) "\" Trim(ExeFile), %ConfigFile%, Settings, FullPath
    IniWrite %Path%, %ConfigFile%, Settings, Path
    IniWrite %ExeFile%, %ConfigFile%, Settings, ExeFile
    IniWrite % Title := "Ready to start you're game", %ConfigFile%, Settings, Title
    IniWrite % OnTop := 0, %ConfigFile%, Settings, OnTop
    
    Reload()
Return


ButtonStartGame:
    ; When the title holds a vanlue, and it is not "Ready to start you're..."
    ; Thus a game needs to be loaded
    If ((Title > 0) & (InStr(Title ,"Ready to start you're game") = 0)) {
        If (!(HwndClient := WinExist("ahk_class " ClientGuiClass))) {
        
            Run %FullPath%, %Path%
            
        }
        
        WinWait ahk_class %ClientGuiClass%
        WinGet Style, Style
        WinGet ExStyle, ExStyle

        ; Remove AlwaysOnTop from a fullscreen window. It's anoying behavier.
        if ((Style = FullScreen) & (ExStyle = AppwindowAlwaysOnTop)) {
        
            WinSet, ExStyle, % "-" WS_EX_TOPMOST, ahk_class %ClientGuiClass%
            
        }

        WinActivate ahk_class %ClientGuiClass%
        WinSet Top,, ahk_class %ClientGuiClass%

        ; Skip creating group and hotkey again once the game is launched.
        if (!ClientGroup, ClientGroup := 1) {
        
            GroupAdd ClientGroup, ahk_class %ClientGuiClass%
            Hotkey IfWinActive, ahk_class %ClientGuiClass%
            Hotkey ~%hKey%, HotKeyAutoWalk, On
            
        }
    }
    ; A new game is added to the script 
    Else If (Title = "Ready to start you're game") {
    
        Text := "WAIT UNTIL THE MAIN GAME WINDOW IS FULLY LOADED!`n`nThen press escape to close this window even if you don't see it anymore!`n"
        Gui % (OnTop ? "+" : "-") "AlwaysOnTop"
        WinSet, Bottom,, AutoWalk
        Gui 1:+Disabled

        Gui ClipMsg:+LastFound +AlwaysOnTop hwndhClipMsg -border -Caption -SysMenu
        Gui ClipMsg:Margin, 10, 12
        Gui ClipMsg:font, c0xFFFFFF s%FontSize%
        Gui ClipMsg:color, 0x000000
        Gui ClipMsg:Add, Text, r4, %Text%
        Gui ClipMsg:Show, % "Y" (A_ScreenHeight // 4), ClipMsg
        WinSet, Transparent, 210, ahk_id %hClipMsg%

        Hotkey, IfWinExist, ClipMsg
        Hotkey, ~*Vk1B, ClipMsgEscape, On   ; Vk1B = Escape

        sleep 5000
        Run %FullPath%, %Path%
        WinWaitClose, ClipMsg
        GoSub, ButtonStartGame
        
        Return

        ClipMsgEscape:
        
            Keywait()
            Hotkey, ~*Vk1B, ClipMsgEscape, Destroy
            Gui ClipMsg:Destroy
            Gui 1:-Disabled

            WinGetTitle, Title, ahk_exe %ExeFile%
            WinGetClass, ClientGuiClass, ahk_exe %ExeFile%

            IniWrite %Title%, %ConfigFile%, Settings, Title
            IniWrite %ClientGuiClass%, %ConfigFile%, Settings, ClientGuiClass

            GuiControl([[ , "Title", Title]])
            
        Return
    
    } Else if (!Title) {
    
        Return
    }
Return

ButtonOpenFolder:
    KeyWait("LButton")
    
    ; Ctrl+LClick or RClick, Opens the current folder where the script is running from.
    If ((GetKeyState("LControl", "P")) | (GetKeyState("RControl", "P"))) {
    
        Run, Explorer.exe "%A_ScriptDir%"

    ; Open the folder where the game .exe is running from.
    } else {
    
        Run, Explorer.exe "%Path%"
        
    }
Return

ShowGameList:   ; Checkbox
    Menu OptionsMenu, ToggleCheck, Show Game List

    if (ShowGameList := ShowGameList ? 0 : 1) {

        GuiControl([["Show", "GBGameList"], ["Show","ListviewActions"]])
        WinMove, AutoWalk,,,, 963
        Menu, OptionsMenu, Check, Show Game List
        IniWrite, %ShowGameList%, %ConfigFile%, Settings, ShowGameList
        
    } else {
    
        GuiControl([["Hide", "GBGameList"], ["Hide","ListviewActions"]])
        WinMove, AutoWalk,,,, 573
        Menu, OptionsMenu, Uncheck, Show Game List
        IniDelete, %ConfigFile%, Settings, ShowGameList
        
    }
Return

RPGGames:   ; Checkbox
    GUI, submit, nohide

    if (RPGGames) {
    
        GuiControl([[ , "hKey", "LButton"], [ , "sKey", "LButton"], ["Enable", "TurnCamera"]])
        IniWrite, %RPGGames%, %ConfigFile%, Settings, RPGGames
        IniWrite, % hKey := "LButton", %ConfigFile%, Settings, hKey
        IniWrite, % sKey := "LButton", %ConfigFile%, Settings, sKey
        
    } else {
    
        ;TurnCamera := ""
        GuiControl([["enable", "hKey"], ["Disable", "TurnCamera"], ["Disable", "LeftKey"], ["Disable", "RightKey"], [ , "TurnCamera", "0"]])
        IniDelete, %ConfigFile%, Settings, TurnCamera
        IniDelete, %ConfigFile%, Settings, RPGGames
        
    }
    GUI, submit, nohide
Return

TurnCamera: ; Checkbox
    GUI, submit, nohide

    if (TurnCamera) {
    
        GuiControl([["Enable", "LeftKey"], ["Enable", "RightKey"]])
        IniWrite, %TurnCamera%, %ConfigFile%, Settings, TurnCamera
        
    } else {
    
        GuiControl([["Disable", "LeftKey"], ["Disable", "RightKey"]])
        IniDelete, %ConfigFile%, Settings, TurnCamera
        
    }
    
    GUI, submit, nohide
Return

TriggerPot: ; Timer
    If (!WinActive(Title))
        return

    PixelSearch, p1X, p1Y, Pot1X, Pot1Y, Pot1X, Pot1Y, Pot1Color, 10, RGB
    PixelSearch, p2X, p2Y, Pot2X, Pot2Y, Pot2X, Pot2Y, Pot2Color, 10, RGB

    If ((!p1X & !p1Y) || (!p2X & !p2Y)) {
    
        If (!p1X & !p1Y) {
        
            If (Pot1Range = Pot1)
                Pot1 := ""

            If (!Pot1 && Pot1 <= Pot1Range) {
            
                Send, {1 down}{1 up}
                Pot1 := "1"
                
            } else If (Pot1 = "1" && Pot1 <= Pot1Range) {
            
                Send, {2 down}{2 up}
                Pot1 := "2"
                
            } else If (Pot1 = "2" && Pot1 <= Pot1Range) {
            
                Send, {3 down}{3 up}
                Pot1 := "3"
                
            } else If (Pot1 = 3 && Pot1 <= Pot1Range) {
            
                Send, {4 down}{4 up}
                Pot1 := "4"
                
            } else if (Pot1 = 4 && Pot1 <= Pot1Range) {
                Send, {5 down}{5 up}
                Pot1 := "5"
            }
        }
        If (!p2X & !p2Y) {
        
            If (Pot2 = "5" || Pot2 = "")
                Pot2 := Pot1Range

            If (Pot2 = 0) {
            
                Send, {1 down}{1 up}
                Pot2 := "1"
            
            } else If (Pot2 = 1) {
            
                Send, {2 down}{2 up}
                Pot2 := "2"
            
            } else If (Pot2 = 2) {
            
                Send, {3 down}{3 up}
                Pot2 := "3"
            
            } else If (Pot2 = 3) {
            
                Send, {4 down}{4 up}
                Pot2 := "4"
            
            } else if (Pot2 = 4) {
            
                Send, {5 down}{5 up}
                Pot2 := "5"
            
            }
        }
        Sleep % Random(1955, 3300)
    }
return

QuitGame:
Return

GuiEscape:
GuiClose:
    ExitApp


HotKeyAutoWalk:
    if (!IsObject(Walk)) {
    
        Walk := New Autowalk("w", "LButton")
        Start := Walk.Start
        Stop := Walk.Stop
        WalkEnabled := 0
    }
    
    if (!RPGGames && IsObject(Walk)) {
    
        WalkEnabled := WalkEnabled = 0 ? Walk.Start() : Walk.Stop()
        
    ; When enabled, you need to press the hotkey twice to trigger the key to send.
    } else if (RPGGames = 1) {
    
        If (A_Hotkey := KeyWait()) {
        
            If (ErrLvL := KeyWait(A_hotKey, "D T0.2", 1) = 0) {
                
                keywait(A_hotKey)
                KeyState := KeyState != "Down" ? "Down" : "Up"
                Send {%sKey% %KeyState%}

                If ((TurnCamera = 1) & (KeyState = "Down")) {
                
                    AutoTurnCamera(A_hotKey, LeftKey, RightKey, VirtualKey := 1)
                    
                }
            } else {
            
                if (KeyState = "Down") {
                
                    KeyState := "Up"
                    Send {%sKey% %KeyState%}
                    
                }
            }
        }
    }
Return
