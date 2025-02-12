#Include "./Tabs/FlowModes.ahk"
#Include "./Tabs/History.ahk"
#Include "./Tabs/ServerAgentPanel.ahk"

Tabs(App) {

	return (
		Tab3 := App.AddTab3("x15" . " Choose" . config.read("tabPos"), ["Flow Modes", "History", "ServerAgents"]),
		Tab3.OnEvent("Change", (*) => config.write("tabPos", Tab3.Value))

		Tab3.UseTab(1),
		FlowModes(App),

		Tab3.UseTab(2),
		History(App),

		Tab3.UseTab(3),
		ServerAgentPanel(App),

		Tab3.UseTab()
	)
}