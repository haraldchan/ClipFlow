OnDayGroups(App, selectedGroup) {
    monthFolder := Format("\\10.0.2.13\fd\9-ON DAY GROUP DETAILS\{1}\{1}{2}", A_Year, A_MM)
    XL_FILE_PATH := ""
    arrvingGroups := signal([])

    loop files monthFolder . "\*.xlsx" {
        if (InStr(A_LoopFileName, FormatTime(A_Now, "yyyyMMdd"))) {
            XL_FILE_PATH := A_LoopFileFullPath
            break
        }
    }

    if (XL_FILE_PATH == "") {
        MsgBox("未找到 OnDayGroup Excel 文件，请手动添加", popupTitle, "4096 T1")
        App.Opt("+OwnDialogs")
        XL_FILE_PATH := FileSelect(3, , "请选择 OnDayGroup Excel 文件")
        if (XL_FILE_PATH == "") {
            config.write("moduleSelected", 1)
            utils.cleanReload(winGroup)
        }
    }

    arrvingGroups.set(getBlockInfo(XL_FILE_PATH))
    getBlockInfo(fileName) {
        blockInfo := []

        Xl := ComObject("Excel.Application")
        OnDayGroupDetails := Xl.Workbooks.Open(fileName).Worksheets("Sheet1")
        loop {
            blockCodeReceived := OnDayGroupDetails.Cells(A_Index + 3, 1).Text
            blockNameReceived := OnDayGroupDetails.Cells(A_Index + 3, 2).Text
            if (blockCodeReceived = "" || blockCodeReceived = "Group StayOver") {
                break
            }

            blockInfo.Push(
                Map(
                    "blockName", blockNameReceived,
                    "blockCode", blockCodeReceived
                )
            )
        }
        Xl.Workbooks.Close()
        Xl.Quit()

        selectedGroup.set(blockInfo[1])
        return blockInfo
    }

    return (
        App.ARText("w300 h20 0x200", "今日团队")
           .OnEvent("Click", (*) => Run(XL_FILE_PATH))
           .SetFont("bold s11 q4"),
        
        ; group selector radios
        arrvingGroups.value.map(group => 
            App.AddRadio((A_Index = 1 ? "Checked " : "") . "h28 w200 y+10", Format("{1} - {2}", group["blockName"], group["blockCode"]))
               .OnEvent("Click", (*) => selectedGroup.set(group))
        )
    )
}