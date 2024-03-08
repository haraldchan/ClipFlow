#Include "../Tabs/FlowModes.ahk"
#Include "../Tabs/History.ahk"

Tabs(CF, popupTitle, config) {
	
	return (
		Tab3 := CF.AddTab3("w280 x15" . " Choose1", ["Flow Modes", "History"]),
		Tab3.UseTab(1),
		FlowModes(CF, config),

		Tab3.UseTab(2),
		History(CF, config),

		Tab3.UseTab()
	)
}