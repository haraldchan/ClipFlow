#Include "../Tabs/FlowModes.ahk"
#Include "../Tabs/History.ahk"

; Tabs(CF, popupTitle, config) {
Tabs(CF, popupTitle) {
	; saveCurrentTab(curTab) {
		; udpatedConfig := configRead(CONFIG_FILE)
		; udpatedConfig["app"]["tabPos"] := curTab
		; configSave(CONFIG_FILE, udpatedConfig)
	; }

	return (
		Tab3 := CF.AddTab3("w280 x15" . " Choose1", ["Flow Modes", "History"]),
		; Tab3.OnEvent("Change", (*) => saveCurrentTab(Tab3.Value))
		Tab3.OnEvent("Change", (*) => config.write(, Tab3.Value))

		Tab3.UseTab(1),
		; FlowModes(CF, config),
		FlowModes(CF),

		Tab3.UseTab(2),
		; History(CF, config),
		History(CF),

		Tab3.UseTab()
	)
}