RH_SettingsCtripOta(App) {

    return (
        ; profile
        App.AddGroupBox("Section x35 y+20 w330 r5", "基本信息").SetFont("bold"),
        ; profile name
        App.AddText("xs10 yp+25 w65 h25 0x200", "OTA 现付"),
        App.AddEdit("x+10 h25 w230", ""),
        App.AddText("xs10 y+10 w65 h25 0x200", "OTA 预付"),
        App.AddEdit("x+10 h25 w230", ""),
        ; profile type
        App.AddText("xs10 y+10 w65 h25 0x200", "Profile 类型"),
        App.AddRadio("x+20 h25 Checked", "Travel Agent"),
        App.AddRadio("x+10 h25", "Company"),


        ; related fields
        App.AddGroupBox("Section x35 y+30 w330 r5", "预订填入内容").SetFont("bold"),
        ; rate code
        App.AddText("xs10 yp+25 w65 h25 0x200", "Rate Code"),
        App.AddEdit("x+10 h25 w70", ""),
        App.AddEdit("x+10 h25 w70", "(单早)").SetFont("c0x808080"),
        App.AddEdit("x+10 h25 w70", "(双早)").SetFont("c0x808080"),
        ; res. type
        App.AddText("xs10 y+10 w65 h25 0x200", "Res. Type"),
        App.AddEdit("x+10 h25 w230", ""),    
        ; market code
        App.AddText("xs10 y+10 w65 h25 0x200", "预订来源"),
        App.AddText("x+10 h25 0x200", "Mkt."),
        App.AddEdit("x+10 h25 w75", ""), 
        ; source code
        App.AddText("x+13 h25 0x200", "Src."),
        App.AddEdit("x+10 h25 w75", ""),


        0
    )
}