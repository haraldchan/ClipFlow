#Requires AutoHotkey v2.0
#SingleInstance Force
#Include "./src/App.ahk"

; Initialize
CoordMode "Mouse", "Screen"
TraySetIcon A_ScriptDir . "\src\Assets\CFTray.ico"

version := "1.2.0"
popupTitle := "ClipFlow " . version
CONFIG_FILE := "./clipflow.config.json"

if (!FileExist(A_MyDocuments . "\clipflow.config.json")) {
	FileCopy(CONFIG_FILE, A_MyDocuments)
}

; Gui
ClipFlow := Gui(, popupTitle)

App(ClipFlow, popupTitle, CONFIG_FILE)

ClipFlow.Show()

Pause:: ClipFlow.Show()
#Hotif WinActive(popupTitle)
Esc:: ClipFlow.Hide()