#Include <LibIndex>
#Include "./Components/Tabs.ahk"

App(CF, popupTitle, CONFIG_FILE) {
	OnClipboardChange(addToHistory)

	onTop := ReactiveSignal(false)
	config := configRead(CONFIG_FILE)

	keepOnTop(*){
		onTop.set(onTop => !onTop)
		WinSetAlwaysOnTop onTop.value, popupTitle
	}

	clearList(*) {
	    FileDelete(CONFIG_FILE)
	    FileCopy(CONFIG_FILE, A_MyDocuments)
    	utils.cleanReload(winGroup)
	}

	addToHistory(*) {
		if (A_Clipboard = "") {
        	return
    	}
    	if (config["clipHistory"].Length = 10) {
    		config["clipHistory"].Pop()
    	}
    	config["clipHistory"].InsertAt(1, A_Clipboard)
    	configSave(CONFIG_FILE, config)
	}

	
	return (
		CF.AddCheckbox("h25 x15", "保持 ClipFlow 置顶    / 停止脚本: Ctrl+F12")
		.OnEvent("Click", keepOnTop),
		
		Tabs(CF, popupTitle, config),

		ClipFlow.AddButton("h30 w130", "Clear").OnEvent("Click", clearList),
		ClipFlow.AddButton("h30 w130 x+20", "Refresh").OnEvent("Click", (*) => utils.cleanReload(winGroup))
	)


}