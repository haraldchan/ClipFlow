#Include "../lib/LibIndex.ahk"
#Include "./Components/Tabs.ahk"

App(CF) {
	onTop := signal(false)

	keepOnTop(*){
		onTop.set(onTop => !onTop)
		WinSetAlwaysOnTop onTop.value, popupTitle
	}

	clearList(*) {
		FileDelete(config.path)
		config.createLocal()
    	utils.cleanReload(winGroup)
	}

	return (
		onTopCheckBox := CF.AddCheckbox("h25 x15", "保持 ClipFlow 置顶    / 停止脚本: Ctrl+F12"),
		onTopCheckBox.OnEvent("Click", keepOnTop),

		Tabs(CF, onTop, onTopCheckBox),

		ClipFlow.AddButton("h30 w130", "Clear").OnEvent("Click", clearList),
		ClipFlow.AddButton("h30 w130 x+20", "Refresh").OnEvent("Click", (*) => utils.cleanReload(winGroup))
	)
}