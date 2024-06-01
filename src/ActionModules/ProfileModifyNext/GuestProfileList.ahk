GuestProfileList(App, listContent) {
    columnDetails := {
        keys: ["roomNum","name", "gender", "idType", "idNum", "addr"],
        titles: ["房号", "姓名", "性别", "类型", "证件号码", "地址"],
        widths: [50, 90, 40, 80, 145, 120]
    }

    options := {
        lvOptions: "Grid NoSortHdr -ReadOnly -Multi LV0x4000 w550 r15 xp-470 y+10",
        itemOptions: ""
    }

    copyIdNumber(LV, row) {
        A_Clipboard := LV.GetText(row, 5)
        key := LV.GetText(row, 2)
        MsgBox(Format("已复制证件号码: `n`n{1} : {2}", key, A_Clipboard), popupTitle, "4096 T1")
    }

    return (
        App.AddReactiveListView(options, columnDetails, listContent,,["DoubleClick", copyIdNumber])
    )
}