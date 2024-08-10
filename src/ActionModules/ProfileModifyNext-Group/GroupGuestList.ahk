; a guest list component

GroupGuestList(App, loadedGuests) {
    columnDetails := {
        keys: ["roomNum", "name"],
        titles: ["房号", "姓名"],
        widths: [60, 170]
    }

    options := {
        lvOptions: "Checked Grid NoSortHdr LV0x4000 -ReadOnly w245 r16 xp-55 y+10",
        itemOptions: "Check"
    }

    return (
        App.AddCheckBox("vcheckAll h20 y+10", "全选"),
        App.AddReactiveListView(options, columnDetails, loadedGuests),
        ; link check all status
        shareCheckStatus(
            App.getCtrlByName("checkAll"),
            App.getCtrlByType("ListView"),
        )
    )
}