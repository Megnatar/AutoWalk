; Script Global variables
Global Wm_LbuttonDown   := 0x201
, Wm_Mousemove          := 0x200
, Wm_DraggGui           := 0x5050
, WM_NCLBUTTONDOWN      := 0xA1
, Ws_Caption            := 0xC00000
, Ws_Border             := 0x800000
, InputActive           := 0
, TipsOff               := 0
, ConfigFile            := A_ScriptDir "\Settings.ini"
, Profiles              := A_ScriptDir "\GameProfiles\GamesConfig.ini"
, UserCodeFiles         := A_ScriptDir "\GameProfiles\UserCode Files"
, hScriptGui
, hClipMsg
, ControlBelowMouse
, ControlOldBelowMouse
, ctrlTxt
, Title

; Script variables
i                       := 0
RPGGames                := 0
TurnCamera              := 0
Admin                   := 0
ShowGameList            := 0
OnTop                   := 0
IconLib                 := []
FullScreen              := 0xb4000000
AppwindowAlwaysOnTop    := 0x20040808
WS_EX_TOPMOST           := 0x00000008
MenuItems               := {"Toggle Admin": "Admin", "Toggle Tooltips off": "TipsOff", "Toggle OnTop": "OnTop", "Show Game List": "ShowGameList"}
DropNotice              := "Drop you're game executable here"
OpenFolder_TT           := "Open game installation dir.`nControl+Click to open script dir."
hKey_TT                 := "HOTKEY.`nClick then press a button to change."
sKey_TT                 := "SENDKEY.`nClick then press a button to change."
RunGame_TT              := "Start a new game session.`nActivates it, if it's already running."
LeftKey_TT              := "The key used by the game to turn camera left."
RightKey_TT             := "The key used by the game to turn camera right."
Browse_TT               := "Browse for a game to add."
LeftKey                 := "Left"
RightKey                := "Right"
Gui_X                   := "Center"
Gui_Y                   := "Center"
KeyState                := "Up"
sKey                    := "W"
hKey                    := "XButton2"
