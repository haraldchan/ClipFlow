#Include "../lib/LibIndex.ahk"
#Include "./Components/Tabs.ahk"

App(App) {
	onTop := signal(false)

	keepOnTop(*){
		onTop.set(onTop => !onTop)
		WinSetAlwaysOnTop onTop.value, POPUP_TITLE
	}

	clearList(*) {
		if (FileExist(CONFIG.path)) {
			FileDelete(CONFIG.path)
		}
		CONFIG.createLocal()
    	utils.cleanReload(WIN_GROUP)
	}

	return (
		App.AddCheckbox("h20 x15", "保持 ClipFlow 置顶    / 停止脚本: F12")
		   .OnEvent("Click", keepOnTop),

		; tabs
		Tabs(App)
	)
}