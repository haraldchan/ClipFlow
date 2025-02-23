GroupGuestList(App, loadedGuests) {
    columnDetails := {
        keys: ["roomNum", "name", "addr"],
        titles: ["房号", "姓名", "地址"],
        widths: [70, 120, 120]
    }

    options := {
        lvOptions: "Checked Grid NoSortHdr -ReadOnly LV0x4000 w320 r15 y+5",
        itemOptions: "Check"
    }

    return (
        App.AddCheckBox("vcheckAll Checked h20 x380 y135", " 全选").SetFont("bold s10"),
        App.AddReactiveListView(options, columnDetails, loadedGuests),
        ; link check all status
        shareCheckStatus(
            App.getCtrlByName("checkAll"),
            App.getCtrlByType("ListView"),
        )
    )
}