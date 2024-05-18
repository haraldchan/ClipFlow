#Include "./GuestProfileList.ahk"
#Include "./GuestProfileDetails.ahk"
#Include "./PMN_FillIn.ahk"

PMN_App(App, popupTitle, db, identifier) {
    listContent := signal(db.load())
    queryFilter := signal({
        date: FormatTime(A_Now, "yyyyMMdd"),
        search: "",
        period: 60
    })

    searchBy := signal("nameRoom")
    searchByMap := Map(
        "姓名/房号", "nameRoom",
        "地址", "addr",
        "电话", "tel",
        "生日", "birthday",
    )

    handleQuery(ctrlName, newVal) {
        updatedQuery := queryFilter.value

        if (ctrlName = "date") {
            updatedQuery["date"] := FormatTime(newVal, "yyyyMMdd")
        }
        if (ctrlName = "search") {
            updatedQuery["search"] := newVal
        }
        if (ctrlName = "period") {
            updatedQuery["period"] := newVal = "" ? 7200 : newVal
        }

        queryFilter.set(updatedQuery)
    }

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
        listContent.set(handleSearchByConditions(loadedItems))
    }

    handleSearchByConditions(loadedItems) {
        filteredItems := []
        searchInput := queryFilter.value["search"]

        if (searchInput = "") {
            return loadedItems
        }

        if (searchBy.value = "nameRoom") {
            typeConvert(content) {
                converted := ""
                try {
                    converted := Number(content)
                } catch {
                    converted := content
                }
                return converted
            }

            if (typeConvert(searchInput) is Number) {
                ; searching by room number
                for item in loadedItems {
                    if (InStr(item["roomNum"], searchInput)) {
                        filteredItems.InsertAt(1, item)
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
        } else  {
            for item in loadedItems {
                if (InStr(item[searchBy.value], searchInput)) {
                    filteredItems.InsertAt(1, item)
                }
            }
        } 

        return filteredItems
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

    addAddtionalEvents() {
        ; ListView Events
        LV := App.getCtrlByType("ListView")
        LV.OnEvent("ItemEdit", (guiObj, itemIndex) => handleUpdateItem(itemIndex, LV))
        LV.OnEvent("ContextMenu", (params*) => showProfileDetails(params[2], LV))

        handleUpdateItem(itemIndex, LV) {
            selectedItem := listContent.value[itemIndex]
            selectedItem["roomNum"] := LV.GetText(itemIndex, 1)
            db.update(selectedItem["fileName"], queryFilter.value["date"], JSON.stringify(selectedItem))
        }

        showProfileDetails(itemIndex, LV) {
            selectedItem := listContent.value[itemIndex]
            GuestProfileDetails(selectedItem)
        }
    }

    helpInfo := "
    (
        操作指引：

        点击房号`t`t- 修改房号
        鼠标右键`t`t- 显示详细信息
        双击信息`t`t- (主界面中) 复制身份证号
        `t`t`t`t- (详情信息) 复制单条信息
    )"


    return (
        App.AddGroupBox("R17 w550 y+20", popupTitle),
        ; TODO: Add clickable groupbox title, which enable a how-to msgbox that shows quick-keys
        App.AddText("xp10 yp10", popupTitle . " ⓘ")
            .OnEvent("Click", (*) => MsgBox(helpInfo, "Help", "4096"))
        ; date
        App.AddDateTime("vdate xp+10 yp+25 w100 h25 Choose" . queryFilter.value["date"])
            .OnEvent("Change", (ctrl, info) =>
                handleQuery(ctrl.Name, ctrl.Value)
                handleListContentUpdate()),
        ; search conditions
        ; App.AddText("x+10 yp+5 h20", "搜索条件"),
        App.AddDropDownList("x+10 h20", ["姓名/房号", "地址", "电话", "生日"])
            .OnEvent("Change", (ctrl, info) => searchBy.set(searchByMap[ctrl.Text])),
        App.AddEdit("vsearchBox x+5 yp-5 w100 h25", queryFilter.value["search"])
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