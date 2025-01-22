#Include "./Tabs/FlowModes.ahk"
#Include "./Tabs/History.ahk"

Tabs(App) {

	return (
		Tab3 := App.AddTab3("x15" . " Choose" . config.read("tabPos"), ["Flow Modes", "History", "Dev"]),
		Tab3.OnEvent("Change", (*) => config.write("tabPos", Tab3.Value))

		Tab3.UseTab(1),
		FlowModes(App),

		Tab3.UseTab(2),
		History(App),

		Tab3.UseTab(3),
		App.AddButton("h30 w100", "Console").OnEvent("Click", (*) => useDebug.Console())

		Tab3.UseTab()
	)
}