#Include "./Tabs/FlowModes.ahk"
#Include "./Tabs/History.ahk"
#Include "./Tabs/ServerAgentPanel.ahk"
#Include "./Tabs/ReservationHandlerSettings.ahk"

Tabs(App) {
	curModule := CONFIG.read("moduleSelected") ? CONFIG.read("moduleSelected") : 1

	modules := OrderedMap(
		ProfileModifyNext, { 
			name: ProfileModifyNext.name, 
			tabs: ["ServerAgents"], 
			components: [ServerAgentPanel] 
		},
		ProfileModifyNext_Group, { 
			name: ProfileModifyNext_Group.name, 
			tabs: ["ServerAgents"], 
			components: [ServerAgentPanel] 
		},
		ReservationHandler, { 
			name: ReservationHandler.name, 
			tabs: ["更多设置"], 
			components: [ReservationHandlerSettings] 
		},
	)

	curModuleProps := modules.values()[curModule]

	return (
		Tab3 := App.AddTab3("x15" . " Choose" . CONFIG.read("tabPos"), ["Flow Modes", "History", curModuleProps.tabs*]),
		Tab3.OnEvent("Change", (*) => CONFIG.write("tabPos", Tab3.Value))

		Tab3.UseTab(1),
		FlowModes(App, modules.keys()),

		Tab3.UseTab(2),
		History(App),

		curModuleProps.components.map(component => (
			Tab3.UseTab(2 + A_Index), 
			component(App)
		)),

		Tab3.UseTab()
	)
}