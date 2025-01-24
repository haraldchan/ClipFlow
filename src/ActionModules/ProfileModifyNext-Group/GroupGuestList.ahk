GroupGuestList(App, loadedGuests) {
    columnDetails := {
        keys: ["roomNum", "name"],
        titles: ["房号", "姓名"],
        widths: [60, 150]
    }

    options := {
        lvOptions: "Checked Grid NoSortHdr -ReadOnly w245 r14 y+5",
        itemOptions: "Check"
    }

    return (
        App.AddCheckBox("vcheckAll Checked h20 x310 y150", " 全选").SetFont("bold s10"),
        App.AddReactiveListView(options, columnDetails, loadedGuests),
        ; link check all status
        shareCheckStatus(
            App.getCtrlByName("checkAll"),
            App.getCtrlByType("ListView"),
        )
    )
}