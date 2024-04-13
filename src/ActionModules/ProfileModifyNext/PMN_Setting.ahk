PMN_Setting := Gui("+Resize", "Setting")
PMN_Setting.SetFont(, "微软雅黑")

PMN_Window(setting) {
    selectDB(dbKey, ctrlName){
        SelectedFolder := DirSelect(, 3)
            if (SelectedFolder = "") {
                MsgBox("未选择文件夹。", "Setting", "T1")
                return
            } else {
                setting.getCtrlByName(ctrlName).Value := SelectedFolder
                config.write(dbKey, SelectedFolder)
            }
        }

    return (
        setting.AddGroupBox("w300 R10","Profile Modify Next - Setting"),
        ; main
        setting.AddText("xp+10 yp+25 h10","主数据库文件夹"),
        setting.AddEdit("vdbMain w200 h25", config.read("main")),
        setting.AddButton("x+5 w80 h25","选择文件夹").OnEvent("Click", (*) => selectDB("main", "dbMain")),
        ; backup
        setting.AddText("xp-205 y+10 h10","后备数据库文件夹（可选）"),
        setting.AddEdit("vdbBackup w200 h25", config.read("backup")),
        setting.AddButton("x+5 w80 h25","选择文件夹").OnEvent("Click", (*) => selectDB("backup", "dbBackup")),
        ; cleanPeriod
        setting.AddText("xp-205 y+23 h10","保留数据天数： 最近"),
        setting.AddEdit("vPeriod x+5 yp-4 w80 h25", config.read("cleanPeriod")),
        setting.AddText("x+5 yp+4 h10","天")
    )
}