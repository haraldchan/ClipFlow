#Requires AutoHotkey v2.0
#SingleInstance Force
#Include "./src/App.ahk"
CoordMode "Mouse", "Screen"
TraySetIcon A_ScriptDir . "\src\Assets\CFTray.ico"

; global consts
VERSION := "1.5.3"
POPUP_TITLE := "ClipFlow " . VERSION
WIN_GROUP := ["ahk_class SunAwtFrame"]
IMAGES := useImages(A_ScriptDir . "\src\Assets")
CONFIG := useConfigJSON(
	"./clipflow.config.json",
	"clipflow.config.json",
)

; Gui
ClipFlow := Gui(, POPUP_TITLE)
ClipFlow.SetFont(, "微软雅黑")
ClipFlow.OnEvent("Close", (*) => utils.quitApp("ClipFlow", POPUP_TITLE, WIN_GROUP))

App(ClipFlow)

ClipFlow.Show()

; DevToolsUI()

; hotkeys setup
Pause:: ClipFlow.Show()
F11:: utils.cleanReload(WIN_GROUP)
^F11:: {
	if (FileExist(CONFIG.path)) {
		FileDelete(CONFIG.path)
	}
	CONFIG.createLocal()
	utils.cleanReload(WIN_GROUP)
}
#Hotif WinActive(POPUP_TITLE)
Esc:: ClipFlow.Hide()