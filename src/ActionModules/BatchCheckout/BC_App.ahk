#Include "./BatchData.ahk"
#Include "./BC_Execute.ahk"

BC_App(App, popupTitle, db) {
    ids := signal([])
    deps := signal([])
    startTime := signal("00:00")
    endTime := signal("15:00")

    handleInitialize() {
        getData := MsgBox(
            Format("下载已退房数据？`n`n时间范围：{1} - {2}", startTime.value, endTime.value), 
            popupTitle, 
            "OKCancel 4096")

        if (getData = "OK") {
            BatchData.reportFiling(startTime.value, endTime.value)
        }

        today := FormatTime(A_Now, "yyyyMMdd")
        saveFileName := Format(A_MyDocuments . "\{1} - Departures.XML", today)

        if (FileExist(saveFileName)) {
            departedGuests := BatchData.getDepartures(saveFileName)
            deps.set(departedGuests)
            ids.set(BatchData.getDepartedIdsAll(db, departedGuests))
        }
    }

    columnDetails := {
        keys: ["roomNum", "name"],
        titles: ["房号", "姓名"],
        widths: [60, 180]
    }

    options := {
        lvOptions: "Checked Grid NoSortHdr LV0x4000 -ReadOnly w250 r16 xp-160 y+10",
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

    copyIdNumber(LV, row) {
        A_Clipboard := ids.value[row]
        guest := LV.GetText(row, 1) . ": " LV.GetText(row, 2)  
        MsgBox(Format("已复制证件号码: `n`n{1} : {2}", guest, A_Clipboard), popupTitle, "4096 T1")
    }

    helpInfo := "
    (
        1. 请先获取已退房客人信息
        2. 开始退房前，务必先到蓝豆查看“续住”工单，剔除列表中的续住房号
    )"

    return (
        handleInitialize(),
        App.AddGroupBox("R19 y+20 w280"," "),
        App.AddText("xp15 ", popupTitle . " ⓘ ")
           .OnEvent("Click", (*) => MsgBox(helpInfo, "操作指引", "4096")),
        ; time selectors
        App.AddText("h20 y+10 0x200", "退房时间段"),
        
        App.AddComboBox("x+15 w70 Choose3", ["07:00", "15:00", "00:00"])
           .OnEvent("Change", (ctrl, _) => startTime.set(ctrl.Text)),
        
        App.AddText("h20 x+5 0x200", "-"),
        
        App.AddComboBox("x+5 w70 Choose1", ["15:00", "00:00", "07:00"])
           .OnEvent("Change", (ctrl, _) => endTime.set(ctrl.Text)),
        ; departed guests list
        App.AddReactiveListView(options, columnDetails, deps,,["DoubleClick", copyIdNumber]),
        App.AddButton("w120 h30", "获取信息").OnEvent("Click", (*) => handleInitialize()),
        App.AddButton("x+10 w120 h30", "开始退房").OnEvent("Click", (*) => performCheckout())
    )
}