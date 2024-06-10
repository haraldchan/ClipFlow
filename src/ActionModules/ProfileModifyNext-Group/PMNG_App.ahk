#Include "PMNG_Data.ahk"
#Include "PMNG_Execute.ahk"

PMNG_App(App, popupTitle, db) {
    currentGroupName := signal("")
    currentGroupRooms := signal([])
    loadedGuests := signal([])

    handleListInitialize(){
        blockcode := InputBox("请输入 BlockCode", popupTitle)
        if (blockcode.Result = "Cancel") {
            return
        }

        if (!FileExist(A_MyDocuments . "\" . blockcode . ".XML")) {
            PMNG_Data.reportFilling(blockcode.Value)
        }        
        groupInfo := PMNG_Data.getGroupHouseInformations(A_MyDocuments . "\" . blockcode . ".XML")
        guestInfo := PMNG_Data.getGroupGuests(db, groupInfo["inhRooms"])
        
        currentGroupName.set(groupInfo["groupName"])
        currentGroupRooms.set(groupInfo["inhRooms"])
        loadedGuests.set(guestInfo)
    }

    columnDetails := {
        keys: ["roomNum", "name"],
        titles: ["房号", "姓名"],
        widths: [60, 170]
    }

    options := {
        lvOptions: "Checked Grid NoSortHdr LV0x4000 -ReadOnly w245 r16 y+10",
        itemOptions: "Check"
    }

    multiCheck(LV, item, isChecked){
        focusedRows := LV.getFocusedRowNumbers()
        
        for focusedRow in focusedRows {
            LV.Modify(focusedRow, isChecked ? "Check" : "-Check")
        }
    }

    performModify() {
        checkedRows := App.getCtrlByType("ListView").getCheckedRowNumbers()
        selectedGuests := []
        for row in checkedRows {
            selectedGuests.Push(loadedGuests.value[row])
        }

        PMNG_Execute.startModify(currentGroupName.value, currentGroupRooms.value, selectedGuests)
    }

    helpInfo := ""

    return (
        App.AddGroupBox("R19 y+20 w270"," "),
        App.AddText("xp15 ", popupTitle . " ⓘ ")
           .OnEvent("Click", (*) => MsgBox(helpInfo, "操作指引", "4096")),
        App.AddReactiveText("h20 y+10 0x200", "当前团队：{1}" , currentGroupName),

        ; inhouse guests list
        App.AddReactiveListView(options, columnDetails, loadedGuests,, ["ItemCheck", multiCheck]),

        ; btns
        App.AddButton("h30 w75", "保存团单")
           .OnEvent("Click", (*) => handleListInitialize()),
        App.AddButton("vinfo x+10 w75 h30", "获取信息").OnEvent("Click", (*) => handleListInitialize()),
        App.AddButton("vbatch x+10 w75 h30", "开始退房").OnEvent("Click", (*) => performModify())
    )
}