scriptHost := "\\10.0.2.13\fd\19-个人文件夹\HC\Software - 软件及脚本\AHK_Scripts"

scripts := [
    {fileName: scriptHost . "\QM2 For FrontDesk\QM2.ahk", title: "QM2 for FrontDesk"},
    {fileName: scriptHost . "\ClipFlow\ClipFlow.ahk", title: "ClipFlow"},
]

suspendScript(script) {
    DetectHiddenWindows true
    SetTitleMatchMode 1

    ID_FILE_SUSPEND := 65404
    scriptHWND := WinExist(script.title)

    mainMenu := DllCall("GetMenu", "ptr", scriptHWND)
    fileMenu := DllCall("GetSubMenu", "ptr", mainMenu, "int", 0)
    state := DllCall("GetMenuState", "ptr", fileMenu, "uint", ID_FILE_SUSPEND, "uint", 0)
    isSuspended := state >> 3 & 1 

    DllCall("CloseHandle", "ptr", fileMenu)
    DllCall("CloseHandle", "ptr", mainMenu)

    if (!isSuspended) {
        PostMessage 0x0111, 65305,,, script.fileName . " - AutoHotkey"
    }
}

useSingleScript() {
    for script in scripts {
        if (script.fileName = A_ScriptFullPath) {
            continue
        }
        suspendScript(script)
    }
}

; for test only
isItSuspended(){
    DetectHiddenWindows true
    SetTitleMatchMode 1

    ID_FILE_SUSPEND := 65404
    scriptHWND := WinExist("QM2 for FrontDesk")

    mainMenu := DllCall("GetMenu", "ptr", scriptHWND)
    fileMenu := DllCall("GetSubMenu", "ptr", mainMenu, "int", 0)
    state := DllCall("GetMenuState", "ptr", fileMenu, "uint", ID_FILE_SUSPEND, "uint", 0)
    isSuspended := state >> 3 & 1 

    DllCall("CloseHandle", "ptr", fileMenu)
    DllCall("CloseHandle", "ptr", mainMenu)

    return MsgBox(isSuspended = true ? "suspended now" : "normal")
}

; isItSuspended()