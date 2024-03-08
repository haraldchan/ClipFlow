#Include "../ActionModules/ProfileModify/ProfileModify.ahk"
#Include "../ActionModules/InvoiceWechat.ahk"

FlowModes(CF, config) {
	modules := [
		ProfileModify,
		InvoiceWechat,
	]

	moduleSelectedStored := config["app"]["moduleSelected"]
    moduleSelected := moduleSelectedStored > modules.Length ? 1 : moduleSelectedStored

  	moduleRadioStyle(index) {
  		return index = moduleSelected ? "h15 x30 y+10 Checked" : "h15 x30 y+10"
  	}

	return (
		modules.map(module => 
			index := A_Index
			CF.AddRadio(moduleRadioStyle(A_Index), module.name)
				.OnEvent("Click", (r*) => (
					config["app"]["moduleSelected"] := (r[1].value = 1) ? index : 0,
					configSave(CONFIG_FILE, config),
					utils.cleanReload(winGroup)
					)
				)
		),
		modules[moduleSelected].USE(CF)
	)
}