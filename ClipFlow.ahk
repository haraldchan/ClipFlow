#Requires AutoHotkey v2.0
#SingleInstance Force
#Include "./src/App.ahk"
CoordMode "Mouse", "Screen"
TraySetIcon A_ScriptDir . "\src\Assets\CFTray.ico"

; Initializing configuration
version := "1.4.0"
popupTitle := "ClipFlow " . version
winGroup := ["ahk_class SunAwtFrame", "旅客信息"]
config := useConfigJSON(
	"./clipflow.config.json",
	"clipflow.config.json",
)

; Gui
ClipFlow := Gui(, popupTitle)
ClipFlow.SetFont(, "微软雅黑")
ClipFlow.OnEvent("Close", (*) => utils.quitApp("ClipFlow", popupTitle, winGroup))

App(ClipFlow)

ClipFlow.Show()

; hotkeys setup
Pause:: ClipFlow.Show()
F11:: utils.cleanReload(winGroup)
#Hotif WinActive(popupTitle)
Esc:: ClipFlow.Hide()