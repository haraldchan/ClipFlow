#Include "../lib/LibIndex.ahk"
#Include "./Components/Tabs.ahk"

App(CF, popupTitle, CONFIG_FILE) {
	onTop := signal(false)
	config := configRead(CONFIG_FILE)

	keepOnTop(*){
		onTop.set(onTop => !onTop)
		WinSetAlwaysOnTop onTop.value, popupTitle
	}

	clearList(*) {
	    FileDelete(CONFIG_FILE)
	    FileCopy(CONFIG_TEMPLATE, A_MyDocuments)
    	utils.cleanReload(winGroup)
	}

	return (
		CF.AddCheckbox("h25 x15", "保持 ClipFlow 置顶    / 停止脚本: Ctrl+F12").OnEvent("Click", keepOnTop),
		
		Tabs(CF, popupTitle, config),

		ClipFlow.AddButton("h30 w130", "Clear").OnEvent("Click", clearList),
		ClipFlow.AddButton("h30 w130 x+20", "Refresh").OnEvent("Click", (*) => utils.cleanReload(winGroup))
	)
}