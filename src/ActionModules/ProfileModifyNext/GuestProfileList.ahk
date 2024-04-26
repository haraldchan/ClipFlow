GuestProfileList(App, db, listContent) {
    
    ; formatList() {
    ;     LV := App.getCtrlByType("ListView")
    ;     ; column width setting
    ;     LV.ModifyCol(1, 50)
    ;     LV.ModifyCol(2, 100)
    ;     LV.ModifyCol(3, 80)
    ;     LV.ModifyCol(4, 180)
    ;     LV.ModifyCol(5, 115)
    ; }

    columnDetails := {
        keys: ["roomNum","name", "idType", "idNum", "addr"],
        titles: ["房号", "姓名", "类型", "证件号码", "地址"],
        widths: [50, 100, 80, 180, 115]
    }

    options := {
        lvOptions: "LV0x4000 Grid w530 h340 xp-452 y+10",
        itemOptions: ""
    }

    copyIdNumber(LV, row) {
        A_Clipboard := LV.GetText(row, 4)
        key := LV.GetText(row, 2)
        MsgBox(Format("已复制证件号码: `n`n{1} : {2}", key, A_Clipboard), popupTitle, "4096 T1")
    }

    return (
        App.AddReactiveListView(options, columnDetails, listContent,,["DoubleClick", copyIdNumber]),
        ; formatList()
    )
}