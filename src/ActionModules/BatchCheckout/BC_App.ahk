#Include "./BatchData.ahk"
#Include "./BC_Execute.ahk"

BC_App(App, popupTitle, db) {
    ids := signal([])
    deps := signal([])
    startTime := signal("07:00")
    endTime := signal("15:00")

    handleInitialize() {
        getData := MsgBox(
            Format("下载已退房数据？`n`n时间范围：{1} - {2}", startTime.value, endTime.value), 
            popupTitle, 
            "4096")

        if (getData = "Yes") {
            BatchData.reportFiling(startTime.value, endTime.value)
        }

        saveFileName := Format("{1} - Departures", FormatTime(A_Now, "yyyyMMdd")) . ".XML"
        if (FileExist(saveFileName)) {
            departedGuests := BatchData.getDepartures(A_MyDocuments . "\" . saveFileName)
            deps.set(departedGuests)
            ids.set(BatchData.getDepartedIdsAll(db, departedGuests))
        }
    }

    columnDetails := {
        keys: ["roomNum", "name"],
        titles: ["房号", "姓名"],
        widths: [80, 120]
    }

    options := {
        lvOptions: "Checked Grid NoSortHdr -ReadOnly w230 r15",
        itemOptions: "Check"
    }

    performCheckout() {
        checkedRows := App.getCtrlByType("ListView").getCheckedRowNumbers()
        filteredIds := []
        for row in checkedRows {
            filteredIds.Push(ids.value[row])
        }

        BC_Execute.checkoutBatch(filteredIds)
    }

    return (
        handleInitialize(),
        App.AddGroupBox("R17 y+20"," "),
        App.AddText("xp15 ", popupTitle . " ⓘ "),
            ; .OnEvent("Click", (*) => MsgBox(helpInfo, "操作指引", "4096"))
        ; time selectors
        App.AddText("h20 0x200", "退房时间段"),
        
        App.AddComboBox("x+10 h20 Choose1", ["07:00", "15:00", "00:00"])
        .OnEvent("Change", (ctrl, _) => startTime.set(ctrl.Text)),
        
        App.AddText("h20 0x200", "-"),
        
        App.AddComboBox("x+10 h20 Choose1", ["15:00", "00:00", "07:00"])
           .OnEvent("Change", (ctrl, _) => endTime.set(ctrl.Text)),
        ; departed guests list
        App.AddReactiveListView(options, columnDetails, deps),
        App.AddButton("w110 h30", "重新获取").OnEvent("Click", (*) => handleInitialize()),
        App.AddButton("x+10 w110 h30", "开始退房").OnEvent("Click", (*) => performCheckout()),
    )
}