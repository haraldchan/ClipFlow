#Requires AutoHotkey v2.0
#SingleInstance Force
#Include "./src/App.ahk"
CoordMode "Mouse", "Screen"
TraySetIcon A_ScriptDir . "\src\Assets\CFTray.ico"

; Initializing configuration
version := "1.2.0"
popupTitle := "ClipFlow " . version
winGroup := ["ahk_class SunAwtFrame", "旅客信息"]
; CONFIG_TEMPLATE := "./clipflow.config.json"
; CONFIG_FILE := configCreate(CONFIG_TEMPLATE)
config := useConfigJSON(
	"./clipflow.config.json",
	"clipflow.config.json"
)

; configCreate(configTemplate) {
; 	if (!FileExist(A_MyDocuments . "\clipflow.config.json")) {
; 		FileCopy(configTemplate, A_MyDocuments)
; 	}
; 	return A_MyDocuments . "\clipflow.config.json"
; }

; configRead(config) {
; 	return JSON.parse(FileRead(config))
; }

; configSave(configFile, configMap) {
; 	FileDelete(configFile)
; 	FileAppend(JSON.stringify(configMap), configFile)
; }

; Gui
ClipFlow := Gui(, popupTitle)
; App(ClipFlow, popupTitle, CONFIG_FILE)
App(ClipFlow)
ClipFlow.Show()

; hotkeys setup
Pause:: ClipFlow.Show()
#Hotif WinActive(popupTitle)
Esc:: ClipFlow.Hide()