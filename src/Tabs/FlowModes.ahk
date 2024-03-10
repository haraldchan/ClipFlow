#Include "../ActionModules/ProfileModify/ProfileModify.ahk"
#Include "../ActionModules/InvoiceWechat.ahk"
#Include "../ActionModules/ShareClip/ShareClip.ahk"
#Include "../ActionModules/ReservationHandler/ReservationHandler.ahk"

FlowModes(CF) {
	modules := [
		ProfileModify,
		InvoiceWechat,
		ShareClip,
		ResvHandler,
	]

	moduleSelectedStored := config.read("moduleSelected")
    moduleSelected := moduleSelectedStored > modules.Length ? 1 : moduleSelectedStored

  	moduleRadioStyle(index) {
  		return index = moduleSelected ? "h15 x30 y+10 Checked" : "h15 x30 y+10"
  	}

	return (
		modules.map(module => 
			index := A_Index
			CF.AddRadio(moduleRadioStyle(A_Index), module.name)
				.OnEvent("Click", (r*) => (
					config.write("moduleSelected", (r[1].value = 1) ? index : 1),
					utils.cleanReload(winGroup)
				)
			)
		),
		modules[moduleSelected].USE(CF)
	)
}