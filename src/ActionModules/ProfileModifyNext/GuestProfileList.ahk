GuestProfileList(App, db, listContent) {
    
    formatList() {
        LV := App.getCtrlByType("ListView")
        ; column width setting
        LV.ModifyCol(1, 50)
        LV.ModifyCol(2, 100)
        LV.ModifyCol(3, 80)
        LV.ModifyCol(4, 180)
        LV.ModifyCol(5, 115)
    }

    colTitleGrid := {
        keys: ["roomNum","name", "idType", "idNum", "addr"],
        titles: ["房号", "姓名", "类型", "证件号码", "地址"]
    }

    options := {
        lvOptions: "w530 h340 xp-452 y+10",
        itemOptions: ""
    }

    return (
        App.AddReactiveListView(options, colTitleGrid, listContent),
        formatList()
    )
}