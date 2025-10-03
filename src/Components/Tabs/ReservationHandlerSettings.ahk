#Include "./ReservationHandlerSettings/RHS_SettingsWholeSale.ahk"
#Include "./ReservationHandlerSettings/RHS_SettingsCtrip.ahk"
#Include "./ReservationHandlerSettings/RHS_WorkflowOta.ahk"

ReservationHandlerSettings(App) {
    entryParams := CONFIG.read("entryParams")

    agentList := OrderedMap(
        "kingsley", { name: "广州奇利", settingPanel: RHS_SettingsWholeSale , params: entryParams["kingsley"] },
        "jielv", { name: "深圳捷旅", settingPanel: RHS_SettingsWholeSale , params: entryParams["jielv"] },
        "ctrip-ota", { name: "携程 OTA", settingPanel: RHS_SettingsCtrip , params: entryParams["ctrip-ota"] },
        "ctrip-ota-shanglv", { name: "携程商旅尊享", settingPanel: RHS_SettingsCtrip , params: entryParams["ctrip-ota-shanglv"] },
        ; "ctrip-business", { name: "携程商旅协议", settingPanel: RHS_SettingsCtrip , params: entryParams["ctrip-business"] },
        "meituan", { name: "美团酒店", settingPanel: RHS_SettingsWholeSale , params: entryParams["meituan"] }
    )

    selectedAgent := signal(agentList.keys()[1])

    agentComponentSet := Map()
    for agentKey, agentInfo in agentList {
        agentComponentSet[agentKey] := agentInfo.settingPanel.bind(App, agentInfo.params)
    }

    return (
        App.AddText("x30 y+10 w65 h25 0x200", "当前 Agent").SetFont("Bold"),
        App.AddDDL("x+10 w250 Choose1" , agentList.values().map(item => item.name))
           .OnEvent("Change", (ctrl, _) => selectedAgent.set(agentList.keys()[ctrl.Value])),

        Dynamic(selectedAgent, agentComponentSet),
        RHS_WorkflowOta(App)
    )
}
