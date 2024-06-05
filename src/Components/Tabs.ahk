#Include "./Tabs/FlowModes.ahk"
#Include "./Tabs/History.ahk"

Tabs(App, onTop, onTopCheckBox) {
	historyOnTop(curTab){
		prevTab := curTab
		prevOnTop := onTop.value

		if (curTab = 2) {
			onTop.set(true)
			onTopCheckBox.Value := 1
		} else {
			onTop.set(false)
			onTopCheckBox.Value := 0
		}
		WinSetAlwaysOnTop onTop.value, popupTitle
	}

	return (
		Tab3 := App.AddTab3("x15" . " Choose" . config.read("tabPos"), ["Flow Modes", "History", "Dev"]),
		Tab3.OnEvent("Change", (*) => 
			config.write("tabPos", Tab3.Value)
			historyOnTop(Tab3.Value)
		)

		Tab3.UseTab(1),
		FlowModes(App),

		Tab3.UseTab(2),
		History(App),

		Tab3.UseTab(3),
		App.AddButton("h30 w100", "Console").OnEvent("Click", (*) => useDebug.Console())

		Tab3.UseTab()
	)
}