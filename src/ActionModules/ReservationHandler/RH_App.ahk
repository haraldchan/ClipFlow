#Include "./ReservationDetails.ahk"
#Include "./RH_FedexBookingEntry.ahk"

RH_App(App, moduleTitle, identifier) {
    README := FileRead("./README.txt", "UTF-8")

    curResv := signal({})
    OnClipboardChange (*) => handleCaptured(identifier)
    handleCaptured(identifier){
        if (!A_Clipboard.includes(identifier)) {
            return
        }

        curResv.set(JSON.parse(A_Clipboard))
    }

    effect(curResv, cur => handleEntryBtnUpdate(cur))
    handleEntryBtnUpdate(curResv) {
        if (!curResv.value["crewNames"]) {
            return
        }

        entryBtns := [App.getCtrlByName("entry1"), App.getCtrlByName("entry2")]
        crewLastNames := curResv.value["crewNames"].map(name => name.split(" ")[2])

        for btn in entryBtns {
            exist := crewLastNames.has(A_Index)

            btn.Visible := exist
            btn.Text := exist ? crewLastNames[A_Index] : ""
        }
    }

    handleBookingEntry(ctrl, _) {
        if (ctrl.Text == "") {
            return
        }

        FedexBookingEntry.USE(curResv.value, ctrl.Text == "entry1" ? 1 : 2)
    }

    return (
        App.AddGroupBox("Section R18 w685 y+20", ""),
        App.AddText("xp15", moduleTitle),

        ; read me info
        App.AddText("xs10 y+30 h200", README),

        ; reservation info
        App.AddText("x300 w200 h40", "订单详情").SetFont("s13 q5 Bold"),
        ReservationDetails(App, curResv),

        ; entry btns
        App.AddGroupBox("y+10 w200 r2", "录入订单")
        App.AddButton("ventry1 w80 yp+20 Hidden", ""),
        App.AddButton("ventry2 w80 x+10 Hidden", "")
    )
}