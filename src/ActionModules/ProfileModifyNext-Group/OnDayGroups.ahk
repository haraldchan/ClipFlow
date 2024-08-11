OnDayGroups(App, groups, selectedGroup) {
    XL_FILE_PATH := Format("\\10.0.2.13\fd\9-ON DAY GROUP DETAILS\{2}\{2}{3}\{1}Group ARR&DEP.xlsx", FormatTime(A_Now, "yyyyMMdd"), A_Year, A_MM)

    groups.set(getBlockInfo(XL_FILE_PATH))
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

        return blockInfo
    }

    return (
        App.AddText("w300 h20 0x200", "今日团队").SetFont("bold s11 q4"),
        groups.value.map(group => 
            App.AddRadio((A_Index = 1 ? "Checked " : "") . "h22 w200 y+10", Format("{1} - {2}", group["blockName"], group["blockCode"]))
               .OnEvent("Click", (*) => selectedGroup.set(group))
        )
    )
}