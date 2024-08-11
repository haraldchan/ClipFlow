#Include "./OnDayGroups.ahk"
#Include "./GroupGuestList.ahk"
#Include "PMNG_Data.ahk"
#Include "PMNG_Execute.ahk"

PMNG_App(App, popupTitle, db) {
    groups := signal([])
    selectedGroup := signal(Map())

    currentGroupRooms := signal([])
    fetchPeriod := signal(5)
    loadedGuests := signal([])

    handleListInitialize() {
        if (!FileExist(A_MyDocuments . "\" . selectedGroup.value["blockCode"] . ".XML")) {
            PMNG_Data.reportFiling(selectedGroup.value["blockCode"])
        }

        useListPlaceholder(loadedGuests, ["roomNum", "name"], "Loading...")

        groupInfo := PMNG_Data.getGroupHouseInformations(A_MyDocuments . "\" . selectedGroup.value["blockCode"] . ".XML")
        guestInfo := PMNG_Data.getGroupGuests(db, groupInfo["inhRooms"], fetchPeriod.value)

        currentGroupRooms.set(groupInfo["inhRooms"])
        loadedGuests.set(guestInfo)
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
        App.AddGroupBox("R16 y+20 w550", " "),
        App.AddText("xp15 ", popupTitle . " ⓘ ")
        .OnEvent("Click", (*) => MsgBox(helpInfo, "操作指引", "4096")),

        ; shows due in groups
        OnDayGroups(App, groups, selectedGroup),
        App.AddButton("x40 y470 w115 h35", "获取旅客").OnEvent("Click", (*) => handleListInitialize()),
        App.AddButton("x+15 w115 h35", "开始录入").OnEvent("Click", (*) => performModify()),

        ; matching guests
        GroupGuestList(App, loadedGuests)
    )
}