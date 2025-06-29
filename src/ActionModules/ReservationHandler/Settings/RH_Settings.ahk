#Include "./RH_SettingsWholeSale.ahk"
#Include "./RH_SettingsCtrip.ahk"


RH_Settings(*) {
    App := Gui(,"更多设置")
    App.SetFont(, "微软雅黑")

    entryParams := config.read("entryParams")

    return (

    	tabs := App.AddTab3("x15 h500 w370", ["捷旅", "奇利", "携程", "携程商旅"]),
    	tabs.UseTab(1),
    	RH_SettingsWholeSale(App, entryParams["jielv"]),

        tabs.UseTab(2),
        RH_SettingsWholeSale(App, entryParams["kingsley"]),

        tabs.UseTab(3),
        RH_SettingsCtrip(App, ""),

        tabs.UseTab(4),
        RH_SettingsCtrip(App, ""),

        tabs.UseTab(0),

    	App.Show()
    )
}
