#Include "../../ActionModules/action-module-index.ahk"

FlowModes(App) {
	modules := [
		ProfileModifyNext,
		ProfileModifyNext_Group,
		ShareClip,
		ResvHandler,
	]

	moduleNames := modules.map(module => module.name)

	moduleSelectedStored := config.read("moduleSelected")
    moduleSelected := moduleSelectedStored > modules.Length ? 1 : moduleSelectedStored

	return (
		App.AddDropDownList("y+10 w250 Choose" . moduleSelected, moduleNames)
		   .OnEvent("Change", (d*) => 
			config.write("moduleSelected", d[1].value)
			utils.cleanReload(winGroup)
		),
		modules[moduleSelected].USE(App)
	)
}
