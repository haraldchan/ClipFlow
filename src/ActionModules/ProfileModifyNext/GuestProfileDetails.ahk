GuestProfileDetails(selectedGuest, fillIn, App) {
    Profile := Gui("+AlwaysOnTop", "Profile Details")
    Profile.SetFont(, "微软雅黑")

    fieldIndex := Map(
        "addr", "地址",
        "birthday", "生日",
        "gender", "性别",
        "idNum", "证件号码",
        "idType", "证件类型",
        "name", "全名",
        "guestType", "旅客类型",
        "roomNum", "房号",
        "tel", "联系电话",
        "fileName", "登记时间"
    )

    listInitialize(selectedGuest, fieldIndex) {
        LV := Profile.getCtrlByType("ListView")

        for key, field in fieldIndex {
            val := selectedGuest.has(key) ? selectedGuest[key] : ""
            if (key = "fileName") {
                y := SubStr(val, 1, 4)
                m := SubStr(val, 5, 2)
                d := SubStr(val, 7, 2)
                h := SubStr(val, 9, 2)
                min := SubStr(val, 11, 2)

                val := Format("{1}/{2}/{3} {4}:{5}", y, m, d, h, min)
            }

            LV.Add(, field, val)
        }
    }

    copyListField(LV, row) {
        A_Clipboard := LV.GetText(row, 2)
        key := LV.GetText(row, 1)
        MsgBox(Format("已复制信息: `n`n{1} : {2}", key, A_Clipboard), popupTitle, "4096 T1")
    }

    fillInPms(){
        profile.Destroy()
        fillIn(App)
    }

    return (
        Profile.AddListView("vguestProfile LV0x4000 Grid w230 r10", ["信息字段", "证件信息"]).OnEvent("DoubleClick", copyListField),
        listInitialize(selectedGuest, fieldIndex),
        Profile.AddButton("h30 w110", "关 闭 (&C)").OnEvent("Click", (*) => profile.Destroy()),
        Profile.AddButton("x+10 h30 w110 Default", "填   入").OnEvent("Click", (*) => fillInPms()),
        Profile.Show()
    )
}