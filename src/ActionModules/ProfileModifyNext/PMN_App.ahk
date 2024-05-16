#Include "./GuestProfileList.ahk"
#Include "./GuestProfileDetails.ahk"
#Include "./PMN_FillIn.ahk"

PMN_App(App, popupTitle, db, identifier) {
    listContent := signal(db.load())
    queryFilter := signal({
        date: FormatTime(A_Now, "yyyyMMdd"),
        nameRoom: "",
        period: 60
    })

    OnClipboardChange (*) => handleCaptured(identifier, db)
    handleCaptured(identifier, db) {
        if (!InStr(A_Clipboard, identifier)) {
            return
        }

        updatedGuestInfo := JSON.parse(A_Clipboard)
        updatedGuestInfo["fileName"] := A_Now . A_MSec

        ; save to db
        db.add(JSON.stringify(updatedGuestInfo))
        Sleep 500
        handleListContentUpdate()
        ; show notifier msgbox
        MsgBox(Format("已保存信息：{1}", updatedGuestInfo["name"]), popupTitle, "T1.5")
    }

    handleListContentUpdate() {
        if (queryFilter.value["date"] = FormatTime(A_Now, "yyyyMMdd")) {
            adjustedPeriod := queryFilter.value["period"]
            App.getCtrlByName("period").Enabled := true
        } else {
            adjustedPeriod := 60 * 24 * db.cleanPeriod
            App.getCtrlByName("period").Enabled := false
        }

        loadedItems := db.load(, queryFilter.value["date"], adjustedPeriod)
        filteredItems := []

        typeConvert(content) {
            converted := ""
            try {
                converted := Number(content)
            } catch {
                converted := content
            }
            return converted
        }

        searchInput := typeConvert(queryFilter.value["nameRoom"])

        if (searchInput = "") {
            ; no search value
            filteredItems := loadedItems
        } else if (searchInput is Number) {
            ; searching by room number
            for item in loadedItems {
                if (InStr(item["roomNum"], searchInput)) {
                    filteredItems.unshift(item)
                }
            }
        } else {
            ; searching by name fragment
            for item in loadedItems {
                if (item["guestType"] = "内地旅客") {
                    ; from mainland
                    if (InStr(item["name"], searchInput)) {
                        filteredItems.InsertAt(1, item)
                    }
                } else if (item["guestType"] = "港澳台旅客") {
                    ; from HK/MO/TW
                    if (InStr(item["name"], searchInput) ||
                        InStr(item["nameLast"], searchInput, "Off") ||
                        InStr(item["nameFirst"], searchInput, "Off")
                    ) {
                        filteredItems.InsertAt(1, item)
                    }
                } else {
                    ; from abroad
                    if (InStr(item["nameLast"], searchInput, "Off") ||
                        InStr(item["nameFirst"], searchInput, "Off")
                    ) {
                        filteredItems.InsertAt(1, item)
                    }
                }
            }
        }

        listContent.set(filteredItems)
    }

    handleQuery(ctrlName, newVal) {
        updatedQuery := queryFilter.value

        if (ctrlName = "date") {
            updatedQuery["date"] := FormatTime(newVal, "yyyyMMdd")
        }
        if (ctrlName = "nameRoom") {
            updatedQuery["nameRoom"] := newVal
        }
        if (ctrlName = "period") {
            updatedQuery["period"] := newVal = "" ? 7200 : newVal
        }

        queryFilter.set(updatedQuery)
    }

    fillPmsProfile(App) {
        if (!WinExist("ahk_class SunAwtFrame")) {
            MsgBox("Opera 未启动！ ", "Profile Modify Next", "T1")
            return
        }

        App.Hide()
        sleep 500

        LV := App.getCtrlByType("ListView")
        if (LV.GetNext() = 0) {
            return
        }
        PMN_Fillin.fill(listContent.value[LV.GetNext()])
    }

    addAddtionalEvents(){
        LV := App.getCtrlByType("ListView")
        LV.OnEvent("ItemEdit", (guiObj, itemIndex) => handleUpdateItem(itemIndex, LV))
        LV.OnEvent("ContextMenu", (params*) => showProfileDetails(params[2], LV))
    }

    handleUpdateItem(itemIndex, LV){
        selectedItem := listContent.value[itemIndex]
        selectedItem["roomNum"] := LV.GetText(itemIndex, 1)
        db.update(selectedItem["fileName"], queryFilter.value["date"], JSON.stringify(selectedItem))
    }

    showProfileDetails(itemIndex, LV){
        selectedItem := listContent.value[itemIndex]
        GuestProfileDetails(selectedItem)
    }


    return (
        App.AddGroupBox("R17 w550 y+20", popupTitle),
        ; date
        App.AddDateTime("vdate xp+10 yp+25 w100 h25 Choose" . queryFilter.value["date"])
            .OnEvent("Change", (ctrl, info) => 
                handleQuery(ctrl.Name, ctrl.Value)
                handleListContentUpdate()
        ),
        ; name or room number
        App.AddText("x+10 yp+5 h20", "姓名/房号"),
        App.AddEdit("vnameRoom x+5 yp-5 w100 h25", queryFilter.value["nameRoom"])
            .OnEvent("Change", (ctrl, info) => handleQuery(ctrl.Name, ctrl.Value)),
        ; period
        App.AddText("x+10 yp+5 h20", "最近"),
        App.AddEdit("vperiod Number x+1 yp-5 w30 h25", queryFilter.value["period"])
            .OnEvent("Change", (ctrl, info) => handleQuery(ctrl.Name, ctrl.Value)),
        App.AddText("x+1 yp+5 h25", "分钟"),
        ; manual updating
        App.AddButton("vupdate x+10 yp-8 w80 h30", "刷 新(&R)").OnEvent("Click", (*) => handleListContentUpdate()),
        App.AddButton("vfillIn x+5 w80 h30 Default", "填 入").OnEvent("Click", (*) => fillPmsProfile(App)),
        ; profile list
        GuestProfileList(App, listContent),
        addAddtionalEvents()
    )
}