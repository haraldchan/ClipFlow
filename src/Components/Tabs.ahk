#Include "../Tabs/FlowModes.ahk"
#Include "../Tabs/History.ahk"

Tabs(CF) {

	return (
		Tab3 := CF.AddTab3("w280 x15" . " Choose1", ["Flow Modes", "History"]),
		Tab3.OnEvent("Change", (*) => config.write("tabPos", Tab3.Value))

		Tab3.UseTab(1),
		FlowModes(CF),

		Tab3.UseTab(2),
		History(CF),

		Tab3.UseTab()
	)
}