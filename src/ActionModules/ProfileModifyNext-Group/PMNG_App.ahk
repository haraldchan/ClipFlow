#Include "PMNG_Data.ahk"
#Include "PMNG_Execute.ahk"

PMNG_App(App, popupTitle, db) {
    currentGroupName := signal("")
    currentGroupRooms := signal([])
    fetchPeriod := signal(3)
    loadedGuests := signal([])

    handleListInitialize(){
        blockcode := InputBox("请输入 BlockCode", popupTitle)
        if (blockcode.Result = "Cancel") {
            return
        }

        if (!FileExist(A_MyDocuments . "\" . blockcode.Value . ".XML")) {
            PMNG_Data.reportFiling(blockcode.Value)
        }

        loadedGuests.set([Map("roomNum", "Loading...", "name", "Loading")])

        groupInfo := PMNG_Data.getGroupHouseInformations(A_MyDocuments . "\" . blockcode.Value . ".XML")
        guestInfo := PMNG_Data.getGroupGuests(db, groupInfo["inhRooms"], fetchPeriod.value)
        
        currentGroupName.set(groupInfo["groupName"])
        currentGroupRooms.set(groupInfo["inhRooms"])

        loadedGuests.set(guestInfo)
        App.getCtrlByName("checkAll").Value := true
    }

    performModify() {
        checkedRows := App.getCtrlByType("ListView").getCheckedRowNumbers()
        selectedGuests := []
        for row in checkedRows {
            selectedGuests.Push(loadedGuests.value[row])
        }

        PMNG_Execute.startModify(currentGroupRooms.value, selectedGuests)
    }

    columnDetails := {
        keys: ["roomNum", "name"],
        titles: ["房号", "姓名"],
        widths: [60, 170]
    }

    options := {
        lvOptions: "Checked Grid NoSortHdr LV0x4000 -ReadOnly w245 r16 xp-55 y+10",
        itemOptions: "Check"
    }

    helpInfo := ""

    return (
        App.AddGroupBox("R20 y+20 w270"," "),
        App.AddText("xp15 ", popupTitle . " ⓘ ")
           .OnEvent("Click", (*) => MsgBox(helpInfo, "操作指引", "4096")),

        ; check all btn
        App.AddCheckBox("vcheckAll h20 y+10", "全选"),
        App.AddReactiveText("w200 h20 x+5 0x200", "当前团队：{1}" , currentGroupName).setFont("Bold"),

        ; inhouse guests list
        App.AddReactiveListView(options, columnDetails, loadedGuests),

        ; btns
        App.AddButton("w115 h35", "获取旅客").OnEvent("Click", (*) => handleListInitialize()),
        App.AddButton("x+15 w115 h35", "开始录入").OnEvent("Click", (*) => performModify()),

        ; link check all status
        shareCheckStatus(
            App.getCtrlByName("checkAll"),
            App.getCtrlByType("ListView"),
        )
    )
}