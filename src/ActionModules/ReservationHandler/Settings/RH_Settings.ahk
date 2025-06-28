#Include "./RH_SettingsWholeSale.ahk"
#Include "./RH_SettingsCtripOta.ahk"
#Include "./RH_SettingsCtripCor.ahk"

RH_Settings(*) {
    App := Gui(,"更多设置")
    App.SetFont(, "微软雅黑")

    return (

    	tabs := App.AddTab3("x15 h500 w370", ["捷旅", "奇利", "携程", "携程商旅"]),
    	tabs.UseTab(1),
    	RH_SettingsWholeSale(App),

        tabs.UseTab(2),
        RH_SettingsWholeSale(App),

        tabs.UseTab(3),
        RH_SettingsCtripOta(App),

        tabs.UseTab(4),
        RH_SettingsCtripCor(App),

        tabs.UseTab(0),

    	App.Show()
    )
}

; RH_Settings()

; F2::{
; 	Reload
; }