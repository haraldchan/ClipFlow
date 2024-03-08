#Include "../packages/revue/revue.ahk"
#Include "../packages/revue/typeChecker.ahk"
#Include "../packages/JSON.ahk"
#Include "../packages/utils.ahk"
#Include "../packages/defineArrayMethods.ahk"

App(CF, popupTitle, CONFIG_FILE) {
	onTop := ReactiveSignal(false)
	config := configRead(CONFIG_FILE)

	configRead(config) {
		return JSON.parse(FileRead(config))
	}

	configSave(configFile, configMap) {
		FileDelete(configFile)
		FileAppend(JSON.stringify(configMap), configFile)
	}

	keepOnTop(*){
		onTop.set(onTop => !onTop)
		WinSetAlwaysOnTop onTop.value, popupTitle
	}

	
	CF.AddCheckbox("h25 x15", "保持 ClipFlow 置顶    / 停止脚本: Ctrl+F12").OnEvent("Click", keepOnTop),

}