#Include "./GuestProfileDetails.ahk"

GuestProfileList(App, fdb, db, listContent, queryFilter, searchBy, fillPmsProfile) {
    isDateBaseTester := ProfileModifyNext.testers.find(tester => tester == A_ComputerName)

    columnDetails := {
        keys: ["roomNum","name", "gender", "idType", "idNum", "addr"],
        titles: ["房号", "姓名", "性别", "类型", "证件号码", "地址"],
        widths: [70, 120, 45, 80, 180, 150]
    }

    options := {
        lvOptions: "$guestProfileList Grid -ReadOnly -Multi LV0x4000 w658 r16 xp-580 y+10",
        itemOptions: ""
    }

    getSelectedCell(LV, row, key) {
        return LV.GetText(row, columnDetails.keys.findIndex(item => item == key))
    }

    copyIdNumber(LV, row) {
        A_Clipboard := getSelectedCell(LV, row, "idNum")
        MsgBox(Format("已复制证件号码: `n`n{1} : {2}", getSelectedCell(LV, row, "name"), A_Clipboard), POPUP_TITLE, "4096 T1")
    }
 
    handleUpdateItem(LV, row) {
        selectedItem := listContent.value.find(item => item["idNum"] == getSelectedCell(LV, row, "idNum"))
        selectedItem["roomNum"] := getSelectedCell(LV, row, "roomNum")
        ; FileDB
        SetTimer(() => fdb.updateOne(JSON.stringify(selectedItem), queryFilter.value["date"], selectedItem["fileName"]), -1)
        ; DateDase
        if (isDateBaseTester) {
            db.updateOne(JSON.stringify(selectedItem), queryFilter.value["date"], item => item["tsId"] == selectedItem["tsId"])
        }
    }

    showProfileDetails(LV, row, *) {
        if (row == 0 || row > 10000) {
            return
        }

        selectedItem := listContent.value.find(item => item["idNum"] == getSelectedCell(LV, row, "idNum"))
        GuestProfileDetails(selectedItem, fillPmsProfile, App)
    }

    markAsPrimary(LV, row) {
        if (searchBy.value != "waterfall") {
            return
        }

        selectedItem := listContent.value.find(item => item["idNum"] == getSelectedCell(LV, row, "idNum"))
        if (!selectedItem["name"].includes("👤")) {
            selectedItem["name"] := "👤" . selectedItem["name"]
        } else {
            selectedItem["name"] := selectedItem["name"].replace("👤", "")
        }

        LV.Modify(row,,, selectedItem["name"])

        ; FileDB
        SetTimer(() => fdb.updateOne(JSON.stringify(selectedItem), queryFilter.value["date"], selectedItem["fileName"]), -1)
        ; DateDase
        if (isDateBaseTester) {
            db.updateOne(JSON.stringify(selectedItem), queryFilter.value["date"], item => item["tsId"] == selectedItem["tsId"])
        }
    }

    return (    
        App.AddReactiveListView(options, columnDetails, listContent)
           .SetFont("s10.5")
           .OnEvent(
                "ContextMenu", showProfileDetails,
                "DoubleClick", markAsPrimary,
                "ItemEdit", handleUpdateItem
            )
    )
}