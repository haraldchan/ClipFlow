#Include "./RH_SettingsWholeSale.ahk"
#Include "./RH_SettingsCtrip.ahk"
#Include "./RH_WorkflowOta.ahk"

RH_Settings(*) {
    title := "更多设置"
    if (WinExist(title)) {
        return
    }

    App := Gui(, title)
    App.SetFont(, "微软雅黑")

    entryParams := config.read("entryParams")

    return (
        tabs := App.AddTab3("x15 h500 w370", ["捷旅", "奇利", "携程 OTA", "携程商旅尊享", "携程商旅协议", "美团", "流程设置"]),
        tabs.UseTab(1),
        RH_SettingsWholeSale(App, entryParams["jielv"]),

        tabs.UseTab(2),
        RH_SettingsWholeSale(App, entryParams["kingsley"]),

        tabs.UseTab(3),
        RH_SettingsCtrip(App, entryParams["ctrip-ota"]),

        tabs.UseTab(4),
        RH_SettingsCtrip(App, entryParams["ctrip-ota-shanglv"]),
        
        tabs.UseTab(5),
        ; RH_SettingsCtrip(App, entryParams["ctrip-business"]),
        
        tabs.UseTab(6),
        RH_SettingsWholeSale(App, entryParams["meituan"]),

        tabs.UseTab(7),
        RH_WorkflowOta(App)

        tabs.UseTab(0),

        App.Show()
    )
}