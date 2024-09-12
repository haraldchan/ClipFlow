#Include "./GuestProfileList.ahk"
#Include "./GuestProfileDetails.ahk"
#Include "./Settings.ahk"
#Include "./PMN_FillIn.ahk"
#Include "./PMN_Waterfall.ahk"

PMN_App(App, moduleTitle, db, identifier) {
    RECENT_BACKUP_INTERVAL := 30
    fillOverwrite := signal(false)
    listContent := signal(db.load())
    queryFilter := signal({
        date: FormatTime(A_Now, "yyyyMMdd"),
        search: "",
        period: 60
    })
    
    lvIsCheckedAll := signal(true)
    searchBy := signal("nameRoom")
    searchByMap := Map(
        "姓名/房号", "nameRoom",
        "证件号码", "idNum",
        "地址", "addr",
        "电话", "tel",
        "生日", "birthday",
        "瀑流模式", "waterfall"
    )
    ; handling search conditon changes
    effect(searchBy, new => handleSearchByChange(new))
    handleSearchByChange(cur) {
        LV := App.getCtrlByType("ListView")
        LV.Opt(cur = "waterfall" ? "+Checked +Multi" : "-Checked -Multi")
        App.getCtrlByName("$selectAllBtn").ctrl.visible := cur = "waterfall" ? true : false
        handleListContentUpdate()
    }
    
    currentGuest := signal(Map("idNum", 0))
    OnClipboardChange (*) => handleCaptured(identifier)
    handleCaptured(identifier) {
        if (!InStr(A_Clipboard, identifier)) {
            return
        }

        incomingGuest := JSON.parse(A_Clipboard)

        ; updating from add guest modal
        if (currentGuest.value["idNum"] = incomingGuest["idNum"]
            && incomingGuest["isMod"] = false
        ) {
            handleGuestInfoUpdateFromAdd(incomingGuest)
            MsgBox(Format("已更新信息：{1}", incomingGuest["name"]), popupTitle, "T1.5")

        ; updating from saved guest modal
        } else if (incomingGuest["isMod"] = true) {
            updatedGuest := handleGuestInfoUpdateFromMod(incomingGuest)
            if (updatedGuest = "") {
                return
            }
            MsgBox(Format("已保存修改：{1}", updatedGuest["name"]), popupTitle, "T1.5")

        ; adding guest
        } else {
            incomingGuest["fileName"] := A_Now . A_MSec
            db.add(JSON.stringify(incomingGuest))
            MsgBox(Format("已保存信息：{1}", incomingGuest["name"]), popupTitle, "T1.5")
        }

        currentGuest.set(JSON.parse(A_Clipboard))
        handleListContentUpdate()

        ; update recent backup
        if (DateDiff(A_Now, FileGetTime(db.backup . "\recent.json", "C"), "Minutes") > RECENT_BACKUP_INTERVAL) {
            SetTimer(() => db.createRecentBackup(RECENT_BACKUP_INTERVAL), -1)
        }

        ; restore previous clip to clb
        clipHistory := config.read("clipHistory")
        A_Clipboard := clipHistory.Length > 1 ? clipHistory[1] : ""
    }

    handleGuestInfoUpdateFromAdd(captured) {
        recentGuests := db.load()
        for guest in recentGuests {
            if (guest["idNum"] = captured["idNum"]) {
                captured["fileName"] := guest["fileName"]
                db.updateOne(guest["fileName"], queryFilter.value["date"], JSON.stringify(captured))
                return
            }
        }
    }

    handleGuestInfoUpdateFromMod(updater) {
        recentGuests := db.load(, , 480) ; load guests within 8hrs(a shift)
        matchedGuest := signal(Map())
        items := updater.keys()

        for guest in recentGuests {
            if (guest["tsId"] = updater["tsId"]) {
                for item in items {
                    if (InStr(updater[item], "*")) {
                        continue
                    }
                    guest[item] := updater[item]
                }
                matchedGuest.set(guest)
                break
            }
        }

        try {
            db.updateOne(matchedGuest.value["fileName"], queryFilter.value["date"], JSON.stringify(matchedGuest.value))
        } catch {
            MsgBox("无匹配目标...", popupTitle, "4096 T1.5")
            return
        }

        return matchedGuest.value
    }

    handleListContentUpdate() {
        colTitles := ["roomNum","name", "gender", "idType", "idNum", "addr"]
        useListPlaceholder(listContent, colTitles, "Loading...")

        App.getCtrlByName("period").Enabled := (queryFilter.value["date"] = FormatTime(A_Now, "yyyyMMdd"))

        loadedItems := db.load(, queryFilter.value["date"], queryFilter.value["period"])
        if (loadedItems.Length = 0) {
            useListPlaceholder(listContent, colTitles, "No Data")
            return
        }

        listContent.set(handleSearchByConditions(loadedItems))
        lvIsCheckedAll.set(false)
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
        } else if (searchBy.value = "waterfall"){
            roomNums := StrSplit(queryFilter.value["search"], " ")
            ; filtering all entered room numbers
            for roomNum in roomNums {
                for item in loadedItems {
                    if (InStr(item["roomNum"], roomNum)) {
                        filteredItems.InsertAt(1, item)
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

    fillPmsProfile() {
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

        if (searchBy.value = "waterfall") {
            if (queryFilter.value["search"] = "") {
                MsgBox("瀑流模式必须提供房号。", popupTitle, "T2")
                App.Show()
                return
            }

            selectedGuests := []
            ; pick selected guests
            for row in LV.getCheckedRowNumbers() {
                if (LV.getCheckedRowNumbers()[1] = "0") {
                    MsgBox("未选中 Profile。", popupTitle, "T2")
                    App.Show()
                    return
                }
                selectedGuests.Push(listContent.value[row])
            }

            PMN_Waterfall.cascade(StrSplit(queryFilter.value["search"], " "), selectedGuests)
        } else {
            PMN_Fillin.fill(listContent.value[LV.GetNext()], fillOverwrite.value)
        }
    }

    setHotkeys() {
        HotIfWinActive(popupTitle)
        Hotkey "!f", (*) => App.getCtrlByName("searchBox").Focus()
        Hotkey "!Left", (*) => toggleDate("-")
        Hotkey "!Right", (*) => toggleDate("+")
        Hotkey "!Up", (*) => togglePeriod("+")
        Hotkey "!Down", (*) => togglePeriod("-")
        Hotkey "!a", (*) => toggleSelectAll()

        toggleDate(direction) {
            diff := direction = "-" ? -1 : 1

            dt := App.getCtrlByType("DateTime")

            currentDateTime := dt.Value
            dt.Value := DateAdd(currentDateTime, diff, "Days")
            queryFilter.update("date", FormatTime(dt.Value, "yyyyMMdd"))
            handleListContentUpdate()
        }

        togglePeriod(direction) {
            p := App.getCtrlByName("period")
            if (p.value = "") {
                p.value := 0
            }
            newPeriod := direction = "-" ? p.value - 10 : p.value + 10

            if (newPeriod <= 0) {
                return
            }

            p.value := newPeriod
            queryFilter.update("period", newPeriod)
            handleListContentUpdate()
        }

        toggleSelectAll() {
            if (searchBy.value != "waterfall") {
                return
            }

            lvIsCheckedAll.set(c => !c)
        }
    }

    return (
        App.AddGroupBox("R17 w580 y+20", " "),
        App.AddText("xp15 ", moduleTitle . " ⓘ ")
           .OnEvent("Click", (*) => PMN_Settings(fillOverwrite)),
        
        ; datetime
        App.AddDateTime("vdate xp yp+25 w90 h25 Choose" . queryFilter.value["date"])
           .OnEvent("Change", (ctrl, _) =>
            queryFilter.update("date", FormatTime(ctrl.Value, "yyyyMMdd"))
            handleListContentUpdate()
        ),
        
        ; search conditions
        App.AddDropDownList("x+10 w80 Choose2", ["瀑流模式", "姓名/房号", "证件号码", "地址", "电话", "生日"])
           .OnEvent("Change", (ctrl, _) => searchBy.set(searchByMap[ctrl.Text])),
        
        ; search box
        App.AddReactiveEdit("vsearchBox x+5 w100 h25")
        .OnEvent("Change", (ctrl, _) => queryFilter.update("search", ctrl.Value)),
        
        ; period
        App.AddText("x+10 h25 0x200", "最近"),
        App.AddReactiveEdit("vperiod Number x+1 w30 h25", queryFilter.value["period"])
        .OnEvent("Change", (ctrl, _) => queryFilter.update("period", ctrl.Value = "" ? 60 * 24 : ctrl.Value)),
        App.AddText("x+1 h25 0x200", "分钟"),
        
        ; manual updating btns
        App.AddButton("vupdate x+10 w80 h25", "刷 新(&R)").OnEvent("Click", (*) => handleListContentUpdate()),
        App.AddReactiveButton("vfillIn x+5 w80 h25 Default", "填 入")
           .OnEvent(Map(
                "Click", (*) => fillPmsProfile(),
                "ContextMenu", (ctrl, *) => (fillOverwrite.set(o => !o), ctrl.Text := fillOverwrite.value ? "覆盖填入" : "填 入")
        )),

        ; profile list
        GuestProfileList(App, db, listContent, queryFilter, fillPmsProfile),

        ; select all button
        App.AddReactiveCheckBox("$selectAllBtn Hidden w50 h20 xp6 y+3", "全选"),
        shareCheckStatus(
            App.getCtrlByName("$selectAllBtn"), 
            App.getCtrlByName("$guestProfileList"), 
            { checkStatus: lvIsCheckedAll }
        ),
        ; hotkey setup
        setHotkeys()
    )
}