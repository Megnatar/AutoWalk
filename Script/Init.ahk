; If there is a config file.
If (FileExist(ConfigFile)) {

    ; My iniread function will load all variables from any ini file.
    iniRead(ConfigFile)  
}

; When the script needs admin and is running in user mode.
if ((Admin = 1) & !A_IsAdmin) {

    ; Only load one instance of the script.
    #SingleInstance force
    
    Try {
    
        ; Is the script compilled?
        If (A_IsCompiled) {
            
            ; Run the script again with admin rights.
            Run *RunAs "%A_ScriptFullPath%"
            
        } Else {
            
            ; Run the script again with admin rights when it's not compilled.
            Run *RunAs "%A_AhkPath%" "%A_ScriptFullPath%"
            
        }
    
    ; Catch and show errors.
    } Catch ThisError {
    
        MsgBox % ThisError
    }
    ; Terminate the current running instance of this script.
    ExitApp
}
