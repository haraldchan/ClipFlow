PMN_Settings() {
    if (WinExist("PMN Settings")) {
        return
    }

    Settings := Gui(, "PMN Settings")
    Settings.SetFont(, "微软雅黑")

    helpInfo := "
    (
        =========== 使用说明 ===========

        点击房号`t- 修改房号
        鼠标右键`t- 显示详细信息
        双击信息`t- (主界面中) 复制身份证号
        `t- (详情信息) 复制单条信息

        ============ 快捷键 ============

        Alt+左/右`t- 日期搜索翻页
        Alt+上/下`t- 增减搜索时间  
        Alt+F`t- 搜索框
        Alt+R`t- 根据条件搜索
        Alt+A`t- (瀑流模式下)全选搜索结果
        Enter`t- 填入信息到Profile

        =========== 设置选项 ============
    )"

    return (
        Settings.AddText("x10 w260", helpInfo),

        ; fetch period setting
        ; Settings.AddText("x10 w150 h25 0x200", "默认获取旅客范围（分钟）："),
        ; Settings.AddReactiveEdit("vperiod w80 h25 x+10", "{1}", period),
        
        ; 

        ; btns
        Settings.AddButton("x10 y+15 w120 h35", "取 消(&C)")
            .OnEvent("Click", (*) => Settings.Hide()),
        Settings.AddButton("x+5 w120 h35", "保 存(&S)")
            .OnEvent("Click", (*) => (
                ; period.update("period", Settings.getCtrlByName("").Value),
                Sleep(200),
                Settings.Hide()
            )),

        Settings.Show()
    )
}