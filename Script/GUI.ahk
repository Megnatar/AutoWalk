
; When the variable Title is empty. Set the gui alway's on top. Otherwise, check if variable OnTop is true or not.
GUI % "+LastFound " (!Title ? ("+", OnTop := 1) : (OnTop ? "+" : "-")) "AlwaysOnTop +OwnDialogs +hWndhScriptGui -Theme"

; Create the application menu.
Menu GameMenu, Add, Start Game, MenuActions
Menu GameMenu, Add, Quit Game, MenuActions
Menu GameMenu, Add
Menu GameMenu, Add, Add New Game, MenuActions
Menu Menu, Add, &Game, :GameMenu
Menu OptionsMenu, Add, Toggle Tooltips off, MenuActions
Menu OptionsMenu, Add, Toggle Admin, MenuActions
Menu OptionsMenu, Add, Toggle OnTop, MenuActions
Menu OptionsMenu, Add
Menu OptionsMenu, Add, Show Game List, MenuActions
Menu Menu, Add, &Options, :OptionsMenu
Menu ScriptMenu, Add, Reset Script, MenuActions
Menu ScriptMenu, Add, Reload Script, MenuActions
Menu ScriptMenu, Add
Menu ScriptMenu, Add, Add/Edit Code, MenuActions
Menu ScriptMenu, Add, Spy Glass, MenuActions
menu ScriptMenu, Add, AutoPot, MenuActions
Menu Menu, Add, &Script, :ScriptMenu
Gui Menu, Menu

; Create the gui.
Gui Add, CheckBox, x368 y1 w10 h10 Checked%ShowGameList% vShowGameList gShowGameList -theme +0x1020 +E0x20000
Gui Add, GroupBox, x8 y0 w362 h194 +Center, % Admin ? "" : DropNotice
Gui Add, GroupBox, x16 y8 w345 h64
Gui Font, s10 
Gui Add, Text, x83 y40 w276 +0x200 vTitle, %Title%
Gui Font
Gui Add, Picture, x19 y18 w50 h50 +0x09 vPic, % "HICON:*" hIcon := LoadPicture(FullPath, "GDI+ Icon1 w50", ImageType)
Gui Add, Button, x307 y18 w50 h18 vBrowse, Browse
Gui Add, Button, x16 y160 w70 h23 vRunGame, &Start Game
Gui Add, Button, x88 y160 w70 h23 vOpenFolder, Open Folder
Gui Add, Button, x304 y160 w60 h23 gGuiClose, Exit
Gui Add, Button, x226 y160 w70 h23 gQuitGame, Quit Game
Gui Add, GroupBox, x16 y72 w345 h83
Gui Add, Text, x24 y80 w99 h14, Autowalk keys
Gui Add, Edit, x24 y100 w63 h21 Limit1 -TabStop vhKey, %hKey%
Gui Add, Edit, x24 y126 w63 h21 Limit1 -TabStop vskey, %skey%
Gui Add, CheckBox, x96 y96 w82 h23 Checked%RPGGames% vRPGGames gRPGGames, RPG Games
Gui Add, CheckBox, x96 y120 w82 h23 +Disabled Checked%TurnCamera% vTurnCamera gTurnCamera, Turn Camera
Gui Add, Edit, x184 y120 w60 h21 +Disabled Limit1 -TabStop vLeftKey, %LeftKey%
Gui Add, Edit, x248 y120 w60 h21 +Disabled Limit1 -TabStop vRightKey, %RightKey%
Gui Add, GroupBox, x376 y0 w254 h193 +Hidden vGBGameList
Gui Add, ListView, x384 y16 w240 h169 vListviewActions gListviewActions hWndhLVItems -ReadOnly +Hidden, Icon | Game

LV_ModifyCol(1, 38)  ; Auto-size each column to fit its contents.
LV_ModifyCol(2, 200) ; Make the Size column at little wider to reveal its header.

; See if the RPG game is checked.
if (RPGGames) {

    GuiControl([["Enable", "TurnCamera"]])
    
    if (TurnCamera = 1) {
    
        GuiControl([["Enable", "LeftKey"], ["Enable", "RightKey"]])
    }
}

; Create the menu options from object MenuItems.
For MenuItemTxt, VariableName in MenuItems
{
    if (%VariableName%) {
    
       Menu OptionsMenu, ToggleCheck, % MenuItemTxt
   }
}

; Read variables from ini file. Removes the game from profile, when executable is not available.
Loop, parse, % FileOpen(Profiles, 0).read(), `n, `r
{
    if ((InStr(A_LoopField, "[",, 1, 1)) = 1) {
    
        i += 1, SectionName := StrReplace(A_Loopfield, "["), SectionName := StrReplace(SectionName, "]")
        IniRead, Iconfile, %Profiles%, %SectionName%, FullPath
        
        ; Create icon lib object.
        if (FileExist(Iconfile)) {
        
            IconLib[i, 1] := Iconfile
            IconLib[i, 2] := SectionName
        
        ; Delete you're game from the profile when it doesn't exist on the hdd anymore.
        } else if (!FileExist(Iconfile)) {
            ; Confirm delete.
            MsgBox, 0x24, Delete game., % "This game doesn't exist anymore!`nDo you wish to remove?`n`n"  SectionName ""
            IfMsgBox Yes
            {
                IniDelete, % Profiles, % SectionName
                i -= 1
                
            }       
            
        }
    }
}   i := 0 ; Reset i to zero again.

;load all icons
LoadIcons(IconLib)

; Show the game list if it was previously enabled. And else only display the gui.
if (ShowGameList) {

    GuiControl([["Show", "GBGameList"], ["Show","ListviewActions"]])
    Gui Show, % "w" (Gui_W := 638) " h201 x" Gui_X " y" Gui_Y, AutoWalk
    
} else {

    Gui Show, % "w" (Gui_W := 378) " h201 x" Gui_X " y" Gui_Y, AutoWalk
}
