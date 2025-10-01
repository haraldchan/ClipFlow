#Include "../../ActionModules/action-module-index.ahk"

FlowModes(App, modules) {
	moduleNames := modules.map(module => module.name)

	moduleSelectedStored := CONFIG.read("moduleSelected")
	if (!moduleSelectedStored) {
		moduleSelectedStored := 1
		CONFIG.write("moduleSelected", 1)
	}

    moduleSelected := moduleSelectedStored > modules.Length ? 1 : moduleSelectedStored

	return (
		App.AddDropDownList("y+10 w250 Choose" . moduleSelected, moduleNames)
		   .OnEvent("Change", (d*) => 
			CONFIG.write("moduleSelected", d[1].value)
			utils.cleanReload(WIN_GROUP)
		),
		modules[moduleSelected].USE(App)
	)
}