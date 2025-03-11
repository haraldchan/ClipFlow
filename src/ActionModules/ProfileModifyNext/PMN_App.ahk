#Include "./GuestProfileList.ahk"
#Include "./Settings.ahk"
#Include "./PMN_FillIn.ahk"
#Include "./PMN_Waterfall.ahk"
#include "../../Servers/ProfileModifyNext_Server.ahk"

PMN_App(App, moduleTitle, fdb, db, identifier) {
    ; server agent delegate
    delegate := signal(false)
    serverConnection := signal("")
    serverConnectionStatus := Map(
        "default", "Norm cBlack",
        "后台服务在线", "Bold cGreen",
        "超时无响应", "Bold cRed"
    )
    handleDelegateActivate(ctrl, _) {
        delegate.set(ctrl.Value)
        if (ctrl.Value == false) {
            return
        }
        
        connectionStatus := App.getCtrlByName("connectionStatus")
        ctrl.Enabled := false
        serverConnection.set("尝试连接中...")
        connectionStatus.Visible := true

        SetTimer(() => ((
            pmnAgent.PING() 
                ? (
                    serverConnection.set("后台服务在线"), 
                    SetTimer(() => connectionStatus.Visible := false, -2000)

                )
                : (
                    delegate.set(false), 
                    ctrl.Value := false, 
                    serverConnection.set("超时无响应")
                )
        ), ctrl.Enabled := true) , -100)
    }
    effect(delegate, state => App.getCtrlByName("qm2Agent").Enabled := state)


    ; settings
    settings := signal({ fillOverwrite: false, loadFrom: "FileDB" })
    fillBtnText := computed(
        [delegate, settings], 
        (curDelegate, curSettings) => handleFillInBtnTextUpdate(curDelegate, curSettings)
    )
    handleFillInBtnTextUpdate(curDelegate, curSettings) {
        curOverwrite := curSettings["fillOverwrite"]
        return (curDelegate ? (curOverwrite ? "覆盖代行" : "代 行") : (curOverwrite ? "覆盖填入" : "填 入"))
    }


    ; data states
    listContent := signal(settings.value["loadFrom"] == "FileDB" ? fdb.load() : db.load())
    queryFilter := signal({ date: FormatTime(A_Now, "yyyyMMdd"), search: "", range: 60 })
    

    ; list UI states/effect
    lvIsCheckedAll := signal(true)
    searchBy := signal("nameRoom")
    searchByMap := OrderedMap(
        "瀑流模式", "waterfall",
        "姓名/房号", "nameRoom",
        "证件号码", "idNum",
        "地址", "addr",
        "电话", "tel",
        "生日", "birthday",
        "时间戳 ID", "tsId"
    )
    effect(searchBy, curSearchBy => handleSearchByChange(curSearchBy))
    handleSearchByChange(cur) {
        App.getCtrlByType("ListView").Opt(cur == "waterfall" ? "+Checked +Multi" : "-Checked -Multi")
        App.getCtrlByName("delegateCheckBox").Enabled := cur == "waterfall"
        App.getCtrlByName("$selectAllBtn").ctrl.visible := cur == "waterfall"
        App.getCtrlByText("Party: ").Visible := cur == "waterfall"
        App.getCtrlByName("partyNum").Visible := cur == "waterfall"
        if (cur != "waterfall") {
            App.getCtrlByName("delegateCheckBox").Value := false
            delegate.set(false)
        }
    }
    

    ; incoming data handling
    currentGuest := signal(Map("idNum", 0))
    OnClipboardChange (*) => handleCaptured(identifier)
    handleCaptured(identifier) {
        if (!InStr(A_Clipboard, identifier)) {
            return
        }
        ; save a copy in mem for comparison
        incomingGuest := JSON.parse(A_Clipboard)

        ; updating from add guest modal
        if (currentGuest.value["idNum"] == incomingGuest["idNum"] && !incomingGuest["isMod"]) {
            handleGuestInfoUpdateFromAdd(incomingGuest)
            MsgBox(Format("已更新信息：{1}", incomingGuest["name"]), popupTitle, "T1.5")

        ; updating from saved guest modal
        } else if (incomingGuest["isMod"]) {
            updatedGuest := handleGuestInfoUpdateFromMod(incomingGuest)
            if (updatedGuest == "") {
                return
            }
            MsgBox(Format("已保存修改：{1}", updatedGuest["name"]), popupTitle, "T1.5")

        ; adding guest
        } else {
            ; FileDB
            incomingGuest["fileName"] := A_Now . A_MSec
            incomingGuest["regTime"] := A_Now
            fdb.add(JSON.stringify(incomingGuest))
            ; DateBase
            ; db.add(JSON.stringify(incomingGuest))

            MsgBox(Format("已保存信息：{1}", incomingGuest["name"]), popupTitle, "T1.5")
        }

        currentGuest.set(JSON.parse(A_Clipboard))
        handleListContentUpdate()

        ; restore previous clip to clb
        clipHistory := config.read("clipHistory")
        A_Clipboard := clipHistory.Length > 1 ? clipHistory[1] : ""
    } 

    handleGuestInfoUpdateFromAdd(captured) {
        recentGuests := settings.value["loadFrom"] == "FileDB" ? fdb.load() : db.load()
        for guest in recentGuests {
            if (guest["idNum"] == captured["idNum"]) {
                captured["regTime"] := guest["regTime"]
                captured["fileName"] := guest["fileName"]
                ; FileDB
                fdb.updateOne(JSON.stringify(captured), queryFilter.value["date"], guest["fileName"])
                ; DateBase
                ; db.updateOne(JSON.stringify(captured), queryFilter.value["date"], item => item["tsId"] == guest["tsId"])
                return
            }
        }
    }

    handleGuestInfoUpdateFromMod(updater) {
        recentGuests := settings.value["loadFrom"] == "FileDB" ? fdb.load(, , 60 * 24) : db.load(, 60 * 24)
        matchedGuest := signal(Map())
        items := updater.keys()

        for guest in recentGuests {
            if (guest["tsId"] == updater["tsId"]) {
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
            ; FileDB
            fdb.updateOne(JSON.stringify(matchedGuest.value), queryFilter.value["date"], matchedGuest.value["fileName"])
        } catch {
            MsgBox("无匹配目标...", popupTitle, "4096 T1.5")
            return
        }

        ; try {
            ; DateBase
            ; db.updateOne(JSON.stringify(matchedGuest.value), queryFilter.value["date"], item => item["tsId"] == matchedGuest.value["tsId"])
        ; } catch {
            ; MsgBox("无匹配目标...", popupTitle, "4096 T1.5")
            ; return
        ; }

        return matchedGuest.value
    }

    handleListContentUpdate(*) {
        colTitles := App.getCtrlByType("ListView").arcWrapper.titleKeys
        useListPlaceholder(listContent, colTitles, "Loading...")

        App.getCtrlByName("range").Enabled := (queryFilter.value["date"] == FormatTime(A_Now, "yyyyMMdd"))

        if (settings.value["loadFrom"] == "FileDB") {
            loadedItems := fdb.load(, queryFilter.value["date"], queryFilter.value["range"]) 
        } else {
            loadedItems := db.load(queryFilter.value["date"], queryFilter.value["range"]) 
        }

        if (loadedItems.Length == 0) {
            useListPlaceholder(listContent, colTitles, "No Data")
            return
        }

        listContent.set(handleSearchResultFilter(loadedItems))
        lvIsCheckedAll.set(false)
    }

    handleSearchResultFilter(loadedItems) {
        filteredItems := []
        searchInput := queryFilter.value["search"]

        if (searchInput == "") {
            return loadedItems
        }

        if (searchBy.value == "nameRoom") {
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
                    if (item["guestType"] == "内地旅客") {
                        ; from mainland
                        if (InStr(item["name"], searchInput)) {
                            filteredItems.InsertAt(1, item)
                        }
                    } else if (item["guestType"] == "港澳台旅客") {
                        ; from HK/MO/TW
                        if (InStr(item["name"], searchInput) || InStr(item["nameLast"], searchInput, "Off") || InStr(item["nameFirst"], searchInput, "Off")) {
                            filteredItems.InsertAt(1, item)
                        }
                    } else {
                        ; from abroad
                        if (InStr(item["nameLast"], searchInput, "Off") || InStr(item["nameFirst"], searchInput, "Off")) {
                            filteredItems.InsertAt(1, item)
                        }
                    }
                }
            }
        } else if (searchBy.value == "waterfall"){
            roomNums := StrSplit(queryFilter.value["search"], " ")
            ; filtering all entered room numbers
            for roomNum in roomNums {
                for item in loadedItems {
                    if (InStr(item["roomNum"], roomNum)) {
                        filteredItems.InsertAt(1, item)
                    }
                }
            }

        } else if (searchBy.value == "birthday") {
            bd := StrLen(searchInput) == 8
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


    ; fill in profile by actions
    fillPmsProfile(*) {
        if (!WinExist("ahk_class SunAwtFrame")) {
            MsgBox("Opera 未启动！ ", "Profile Modify Next", "T1")
            return
        }

        App.Hide()
        sleep 500

        LV := App.getCtrlByType("ListView")
        if (LV.GetNext() == 0) {
            return
        }

        if (searchBy.value == "waterfall") {
            if (queryFilter.value["search"] == "") {
                MsgBox("瀑流模式必须提供房号。", popupTitle, "T2")
                App.Show()
                return
            }

            rooms := StrSplit(queryFilter.value["search"], " ")
            party := App.getCtrlByName("partyNum").Text
            App.getCtrlByName("partyNum").Text := ""

            selectedGuests := []
            ; pick selected guests
            for row in LV.getCheckedRowNumbers() {
                if (LV.getCheckedRowNumbers()[1] == "0") {
                    MsgBox("未选中 Profile。", popupTitle, "T2")
                    App.Show()
                    return
                }
                selectedGuests.Push(listContent.value[row])
            }

            if (delegate.value) {
                SetTimer(() => (
                    pmnAgent.delegate({
                        mode: "waterfall",
                        overwrite: settings.value["fillOverwrite"],
                        rooms: rooms,
                        party: party,
                        profiles: selectedGuests
                    })
                ), -250)
            } else {
                PMN_Waterfall.cascade(rooms, selectedGuests, settings.value["fillOverwrite"], party)
            }
        } else {
            targetId := LV.GetText(LV.GetNext(), LV.arcWrapper.titleKeys.findIndex(key => key == "idNum"))
            PMN_Fillin.fill(listContent.value.find(item => item["idNum"] == targetId), settings.value["fillOverwrite"])
        }
    }


    ; QM2 agent
    showQm2Panel(*) {
        if (searchBy.value != "waterfall") {
            return
        }

        LV := App.getCtrlByName("$guestProfileList").ctrl

        selectedGuests := []
        ; pick selected guests
        for checkedRow in LV.getCheckedRowNumbers() {
            if (LV.getCheckedRowNumbers()[1] == "0") {
                QM2_Panel({ sendPm: false})
                return
            }
            selectedGuests.Push(listContent.value[checkedRow])
        }

        QM2_Panel({ selectedGuests: selectedGuests })
    }


    ; hotkey setup
    setHotkeys() {
        HotIfWinActive(popupTitle)
        Hotkey "!f", (*) => App.getCtrlByName("searchBox").Focus()
        Hotkey "!Left", (*) => toggleDate("-")
        Hotkey "!Right", (*) => toggleDate("+")
        Hotkey "!Up", (*) => togglePeriod("+")
        Hotkey "!Down", (*) => togglePeriod("-")
        Hotkey "!a", (*) => toggleSelectAll()

        toggleDate(direction) {
            diff := direction == "-" ? -1 : 1

            dt := App.getCtrlByType("DateTime")
            dt.Value := DateAdd(dt.Value, diff, "Days")
            queryFilter.update("date", FormatTime(dt.Value, "yyyyMMdd"))
            handleListContentUpdate()
        }

        togglePeriod(direction) {
            p := App.getCtrlByName("range")
            if (p.value = "") {
                p.value := 0
            }
            newRange := direction = "-" ? p.value - 10 : p.value + 10

            if (newRange <= 0) {
                return
            }

            p.value := newRange
            queryFilter.update("range", newRange)
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
        App.AddGroupBox("Section R18 w685 y+20", ""),
        App.AddText("xp15", moduleTitle . " ⓘ ").OnEvent("Click", (*) => PMN_Settings(settings)),
        
        ; agent mode
        App.AddCheckBox("vdelegateCheckBox x+10 Disabled", "后台代行").OnEvent("Click", handleDelegateActivate),
        App.ARText("vconnectionStatus x+20 w80 Hidden", " {1}", serverConnection).SetFontStyles(serverConnectionStatus),
        
        ; datetime
        App.AddDateTime("vdate xs15 yp+25 w90 h25 Choose" . queryFilter.value["date"])
           .OnEvent("Change", (ctrl, _) =>
            queryFilter.update("date", FormatTime(ctrl.Value, "yyyyMMdd"))
            handleListContentUpdate()
        ),
        
        ; search conditions
        App.AddDropDownList("x+10 w80 Choose2", searchByMap.keys())
           .OnEvent("Change", (ctrl, _) => searchBy.set(searchByMap[ctrl.Text])),
        
        ; search box
        App.AREdit("vsearchBox x+5 w125 h25")
           .OnEvent("LoseFocus", (ctrl, _) => queryFilter.update("search", Trim(ctrl.Value))),
        
        ; range
        App.AddText("x+10 h25 0x200", "最近"),
        App.AREdit("vrange Number x+1 w30 h25", queryFilter.value["range"])
           .OnEvent("Change", (ctrl, _) => queryFilter.update("range", ctrl.Value = "" ? 60 * 24 : ctrl.Value)),
        App.AddText("x+1 h25 0x200", "分钟"),
        
        ; btns
        App.AddButton("x+10 w80 h25", "刷 新(&R)").OnEvent("Click", handleListContentUpdate),
        App.ARButton("vfillIn x+5 w80 h25 Default", "{1}", fillBtnText)
           .OnEvent(
                "Click", fillPmsProfile,
                "ContextMenu", (*) => settings.update("fillOverwrite", o => !o)
        ),
        App.AddButton("vqm2Agent x+5 w80 h25 Disabled", "&QM2 Agent").OnEvent("Click", showQm2Panel),

        ; profile list
        GuestProfileList(App, fdb, db, listContent, queryFilter, searchBy, fillPmsProfile),

        ; waterfall controls
        App.ARCheckBox("$selectAllBtn Hidden w50 h20 xp6 y+5", "全选"),
        shareCheckStatus(
            App.getCtrlByName("$selectAllBtn"), 
            App.getCtrlByName("$guestProfileList"), 
            { checkStatus: lvIsCheckedAll }
        ),
        App.AddText("Hidden h20 x+10 0x200", "Party: "),
        App.AddEdit("vpartyNum Hidden x+1 w100 h20", ""),

        ; hotkey setup
        setHotkeys()
    )
}