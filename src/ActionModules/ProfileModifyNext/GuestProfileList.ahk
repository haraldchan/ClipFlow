GuestProfileList(App, db, listContent, queryFilter, fillPmsProfile) {
    columnDetails := {
        keys: ["roomNum","name", "gender", "idType", "idNum", "addr"],
        titles: ["房号", "姓名", "性别", "类型", "证件号码", "地址"],
        widths: [60, 90, 40, 80, 145, 120]
    }

    options := {
        lvOptions: "$guestProfileList Grid -ReadOnly -Multi LV0x4000 w550 r15 xp-470 y+10",
        itemOptions: ""
    }

    getSelectedCell(LV, row, key) {
        return LV.GetText(row, columnDetails.keys.findIndex(item => item == key))
    }

    copyIdNumber(LV, row) {
        A_Clipboard := getSelectedCell(LV, row, "idNum")
        MsgBox(Format("已复制证件号码: `n`n{1} : {2}", getSelectedCell(LV, row, "name"), A_Clipboard), popupTitle, "4096 T1")
    }

    handleUpdateItem(LV, row) {
        selectedItem := listContent.value.find(item => item["idNum"] == getSelectedCell(LV, row, "idNum"))
        selectedItem["roomNum"] := getSelectedCell(LV, row, "roomNum")
        ; db.updateOne(JSON.stringify(selectedItem), queryFilter.value["date"], selectedItem["fileName"])
        db.updateOne(JSON.stringify(selectedItem), queryFilter.value["date"], selectedItem["tsId"])
    }

    showProfileDetails(LV, row, *) {
        if (row = 0) {
            return
        }

        selectedItem := listContent.value.find(item => item["idNum"] == getSelectedCell(LV, row, "idNum"))
        GuestProfileDetails(selectedItem, fillPmsProfile, App)
    }

    return (    
        App.AddReactiveListView(options, columnDetails, listContent)
           .OnEvent(Map(
                "DoubleClick", copyIdNumber,
                "ItemEdit", handleUpdateItem,
                "ContextMenu", showProfileDetails
            ))
    )
}