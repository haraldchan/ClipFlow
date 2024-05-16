GuestProfileList(App, listContent) {
    columnDetails := {
        keys: ["roomNum","name", "idType", "idNum", "addr"],
        titles: ["房号", "姓名", "类型", "证件号码", "地址"],
        widths: [50, 90, 80, 160, 135]
    }

    options := {
        lvOptions: "LV0x4000 Grid -ReadOnly w530 h340 xp-452 y+10",
        itemOptions: ""
    }

    copyIdNumber(LV, row) {
        A_Clipboard := LV.GetText(row, 4)
        key := LV.GetText(row, 2)
        MsgBox(Format("已复制证件号码: `n`n{1} : {2}", key, A_Clipboard), popupTitle, "4096 T1")
    }

    return (
        App.AddReactiveListView(options, columnDetails, listContent,,["DoubleClick", copyIdNumber])
    )
}