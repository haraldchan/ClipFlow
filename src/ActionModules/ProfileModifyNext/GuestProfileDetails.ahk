GuestProfileDetails(selectedGuest) {
    profile := Gui(,"Profile Details")
    profile.SetFont(, "微软雅黑")

    fieldIndex := Map(
        "addr", "地址",
        "birthday", "生日",
        "gender", "性别",
        "idNum", "证件号码",
        "idType", "证件类型",
        "name", "全名",
        "guestType", "旅客类型",
        "roomNum", "房号",
        "tel", "联系电话"
    )

    listInitialize(selectedGuest, fieldIndex) {
        LV := profile.getCtrlByType("ListView")

        for key, field in fieldIndex {
            val := selectedGuest.has(key) ? selectedGuest[key] : ""
            LV.Add(, field, val)
        }
    }

    updateList(curGuest, fieldIndex) {
        LV := profile.getCtrlByType("ListView")
        
        for k, v in curGuest {
            LV.Modify(A_Index, , fieldIndex[k], v)
        }
    }

    copyListField(LV, row) {
        A_Clipboard := LV.GetText(row, 2)
        key := LV.GetText(row, 1)
        MsgBox(Format("已复制信息: `n`n{1} : {2}", key, A_Clipboard), popupTitle, "4096 T1")
    }

    return (
        profile.AddListView("vguestProfile LV0x4000 Grid w230 r9", ["信息字段", "证件信息"]).OnEvent("DoubleClick", copyListField),
        listInitialize(selectedGuest, fieldIndex),
        profile.AddButton("h30 w230", "关   闭").OnEvent("Click", (*) => profile.Hide()),
        profile.Show()
    )
}