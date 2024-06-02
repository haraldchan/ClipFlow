#Include "PMNG_Data.ahk"
#Include "PMNG_Execute.ahk"

PMNG_App(App, popupTitle, db) {
    currentGroupName := signal("")
    currentGroupRooms := signal([])
    loadedGuests := signal([])

    handleListInitialize(){
        blockcode := InputBox("请输入 BlockCode",popupTitle, 4096)
        if (blockcode.Result = "Cancel") {
            utils.cleanReload(winGroup)
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
        lvOptions: "Checked Grid NoSortHdr LV0x4000 -ReadOnly w250 r16 xp-160 y+10",
        itemOptions: "Check"
    }

    multiCheck(LV, row){
        itemState := SendMessage(0x102C, row - 1, 0xF000, LV)  
        isChecked := (ItemState >> 12) - 1 

        checkedRows := []
        rowNumber := 0
        loop {
            rowNumber := LV.GetNext(rowNumber, "Focused") 
            if (rowNumber = 0) {
                break
            }
            checkedRows.Push(rowNumber)
        }

        for checkedRow in checkedRows {
            LV.Modify(checkedRow, isChecked ? "Check" : "-Check")
        }
    }

    performModify() {
        checkedRows := App.getCtrlByType("ListView").getCheckedRowNumbers()
        selectedGuests := []
        for row in checkedRows {
            selectedGuests.Push(loadedGuests.value[row])
        }

        PMNG_Execute.startModify(currentGroupRooms.value, selectedGuests)
    }

    helpInfo := ""

    return (
        App.AddGroupBox("R19 y+20 w280"," "),
        App.AddText("xp15 ", popupTitle . " ⓘ ")
           .OnEvent("Click", (*) => MsgBox(helpInfo, "操作指引", "4096")),

        App.AddReactiveText("h20 y+10 0x200", "当前团队：{1}" , currentGroupName),
        App.AddButton("h20 w100", "保存团单")
           .OnEvent("Click", (*) => handleListInitialize())

        ; inhouse guests list
        App.AddReactiveListView(options, columnDetails, loadedGuests,, ["ItemCheck", multiCheck]),
        App.AddButton("vinfo w120 h30", "获取信息").OnEvent("Click", (*) => handleListInitialize()),
        App.AddButton("vbatch x+10 w120 h30", "开始退房").OnEvent("Click", (*) => performModify())
    )
}