#Include "../ActionModules/ProfileModify/ProfileModify.ahk"
#Include "../ActionModules/ProfileModify/ProfileModifyNew.ahk"
#Include "../ActionModules/InvoiceWechat.ahk"
#Include "../ActionModules/ShareClip/ShareClip.ahk"
#Include "../ActionModules/ReservationHandler/ReservationHandler.ahk"

FlowModes(CF) {
	modules := [
		ProfileModify,
		ProfileModifyNew,
		InvoiceWechat,
		ShareClip,
		ResvHandler,
	]

	moduleNames := modules.map(module => module.name)

	moduleSelectedStored := config.read("moduleSelected")
    moduleSelected := moduleSelectedStored > modules.Length ? 1 : moduleSelectedStored

	return (
		CF.AddDropDownList("y+10 w250 Choose" . moduleSelected, moduleNames)
		.OnEvent("Change", (d*) => 
			config.write("moduleSelected", d[1].value)
			utils.cleanReload(winGroup)
		),
		modules[moduleSelected].USE(CF)
	)
}