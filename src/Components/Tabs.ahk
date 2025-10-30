#Include "./Tabs/FlowModes.ahk"
#Include "./Tabs/ClipboadHistory.ahk"
#Include "./Tabs/ServerAgentPanel.ahk"
#Include "./Tabs/ReservationHandlerSettings.ahk"

Tabs(App) {
	curModule := CONFIG.read("moduleSelected") ? CONFIG.read("moduleSelected") : 1

	modules := OrderedMap(
		ProfileModifyNext, { 
			name: ProfileModifyNext.name, 
			tabs: ["后台服务"], 
			components: [ServerAgentPanel] 
		},
		ProfileModifyNext_Group, { 
			name: ProfileModifyNext_Group.name, 
			tabs: ["后台服务"], 
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
		Tab3 := App.AddTab3("x15" . " Choose" . CONFIG.read("tabPos"), ["插件模式", "剪贴板历史", curModuleProps.tabs*]),
		Tab3.OnEvent("Change", (*) => CONFIG.write("tabPos", Tab3.Value))

		Tab3.UseTab("插件模式"),
		FlowModes(App, modules.keys()),	

		Tab3.UseTab("剪贴板历史"),
		ClipboardHistory(App),

		curModuleProps.components.map(component => (
			Tab3.UseTab(2 + A_Index), 
			component(App)
		)),

		Tab3.UseTab()
	)
}