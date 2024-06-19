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
        "证件号码", "idNum",
        "地址", "addr",
        "电话", "tel",
        "生日", "birthday",
    )
    effect(searchBy, () => App.getCtrlByName("searchBox").Value := "")

    handleQuery(ctrlName, newVal) {
        updatedQuery := queryFilter.value.deepClone()

        if (ctrlName = "date") {
            updatedQuery["date"] := FormatTime(newVal, "yyyyMMdd")
        }
        if (ctrlName = "searchBox") {
            updatedQuery["search"] := newVal
        }
        if (ctrlName = "period") {
            updatedQuery["period"] := newVal = "" ? 1440 : newVal
        }

        queryFilter.set(updatedQuery)
    }

    currentGuest := signal(Map("idNum", 0))
    OnClipboardChange (*) => handleCaptured(identifier)
    handleCaptured(identifier) {
        if (!InStr(A_Clipboard, identifier)) {
            return
        }

        incomingGuest := JSON.parse(A_Clipboard)

        if (currentGuest.value["idNum"] = incomingGuest["idNum"]) {
            handleGuestInfoUpdate(incomingGuest)
            MsgBox(Format("已更新信息：{1}", incomingGuest["name"]), popupTitle, "T1.5")
        } else {
            incomingGuest["fileName"] := A_Now . A_MSec
            ; save to db
            db.add(JSON.stringify(incomingGuest))
            MsgBox(Format("已保存信息：{1}", incomingGuest["name"]), popupTitle, "T1.5")
        }

        currentGuest.set(JSON.parse(A_Clipboard))

        Sleep 500
        handleListContentUpdate()

        clipHistory := config.read("clipHistory")
        A_Clipboard := clipHistory.Length > 1 ? clipHistory[1] : ""
    }

    handleGuestInfoUpdate(captured) {
        recentGuests := db.load()
        for guest in recentGuests {
            if (guest["idNum"] = captured["idNum"]) {
                captured["fileName"] := guest["fileName"]
                db.updateOne(guest["fileName"], queryFilter.value["date"], JSON.stringify(captured))
                return
            }
        }
    }

    handleListContentUpdate() {
        listContent.set([
            Map(
                "roomNum", "Loading...",
                "name", "Loading...",
                "gender", "Loading...",
                "idType", "Loading...",
                "idNum", "Loading...",
                "addr", "Loading..."
            )
        ])

        if (queryFilter.value["date"] = FormatTime(A_Now, "yyyyMMdd")) {
            App.getCtrlByName("period").Enabled := true
        } else {
            App.getCtrlByName("period").Enabled := false
        }

        loadedItems := db.load(, queryFilter.value["date"], queryFilter.value["period"])
        if (loadedItems.Length = 0) {
            listContent.set([
                Map(
                    "roomNum", "NO DATA",
                    "name", "NO DATA",
                    "gender", "NO DATA",
                    "idType", "NO DATA",
                    "idNum", "NO DATA",
                    "addr", "NO DATA"
                )
            ])
            return
        }

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
        } else if (searchBy.value = "birthday") {
            bd := StrLen(searchInput) = 8
                ? SubStr(searchInput, 1, 4) . "-" . SubStr(searchInput, 5, 2) . "-" . SubStr(searchInput, 7, 2)
                : searchInput
            for item in loadedItems {
                if (InStr(item[searchBy.value], bd)) {
                    filteredItems.InsertAt(1, item)
                }
            }
        } else {
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
        LV := App.getCtrlByType("ListView")
        LV.OnEvent("ItemEdit", (guiObj, itemIndex) => handleUpdateItem(itemIndex, LV))
        LV.OnEvent("ContextMenu", (params*) => showProfileDetails(params[2], LV))

        handleUpdateItem(itemIndex, LV) {
            selectedItem := listContent.value[itemIndex]
            selectedItem["roomNum"] := LV.GetText(itemIndex, 1)
            db.updateOne(selectedItem["fileName"], queryFilter.value["date"], JSON.stringify(selectedItem))
        }

        showProfileDetails(itemIndex, LV) {
            if (itemIndex = 0) {
                return
            }
            selectedItem := listContent.value[itemIndex]
            GuestProfileDetails(selectedItem, fillPmsProfile, App)
        }

        searchBox := App.getCtrlByName("searchBox")
        searchBox.OnEvent("LoseFocus", (*) => handleListContentUpdate())

        period := App.getCtrlByName("period")
        period.OnEvent("LoseFocus", (*) => handleListContentUpdate())
    }

    hotkeys() {
        Hotkey "^f", (*) => App.getCtrlByName("searchBox").Focus()
    }

    helpInfo := "
    (
        ============ 基本功能 ============

        点击房号`t- 修改房号
        鼠标右键`t- 显示详细信息
        双击信息`t- (主界面中) 复制身份证号
        `t- (详情信息) 复制单条信息

        ============= 快捷键 =============

        Ctrl+F`t- 搜索框
        Alt+R`t- 根据条件搜索
        Enter`t- 填入信息到Profile

    )"

    return (
        App.AddGroupBox("R17 w580 y+20", " "),
        App.AddText("xp15 ", popupTitle . " ⓘ ")
        .OnEvent("Click", (*) => MsgBox(helpInfo, "操作指引", "4096"))
        ; date
        App.AddDateTime("vdate xp yp+25 w90 h25 Choose" . queryFilter.value["date"])
        .OnEvent("Change", (ctrl, info) =>
            handleQuery(ctrl.Name, ctrl.Value)
            handleListContentUpdate()),
        ; search conditions
        App.AddDropDownList("x+10 w80 Choose1", ["姓名/房号", "证件号码", "地址", "电话", "生日"])
        .OnEvent("Change", (ctrl, _) => searchBy.set(searchByMap[ctrl.Text])),
        ; search box
        App.AddEdit("vsearchBox x+5 w100 h25")
        .OnEvent("Change", (ctrl, _) => handleQuery(ctrl.Name, ctrl.Value)),
        ; period
        App.AddText("x+10 yp+5 h20", "最近"),
        App.AddEdit("vperiod Number x+1 yp-5 w30 h25", queryFilter.value["period"])
        .OnEvent("Change", (ctrl, _) => handleQuery(ctrl.Name, ctrl.Value)),
        App.AddText("x+1 yp+5 h25", "分钟"),
        ; manual updating
        App.AddButton("vupdate x+10 yp-8 w80 h30", "刷 新(&R)").OnEvent("Click", (*) => handleListContentUpdate()),
        App.AddButton("vfillIn x+5 w80 h30 Default", "填 入").OnEvent("Click", (*) => fillPmsProfile(App)),
        ; profile list
        GuestProfileList(App, listContent),
        addAddtionalEvents(),
        hotkeys()
    )
}