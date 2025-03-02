#Include "./ReservationDetails.ahk"
#Include "./RH_FedexBookingEntry.ahk"

RH_App(App, moduleTitle, identifier) {
    README := FileRead(A_ScriptDir . "\src\ActionModules\ReservationHandler\README.txt", "UTF-8")

    curResv := signal({})
    resvType := signal("")
    OnClipboardChange (*) => handleCaptured(identifier)
    handleCaptured(identifier){
        if (!A_Clipboard.includes(identifier)) {
            return
        }

        curResv.set(JSON.parse(A_Clipboard))
        config.write("JSON", A_Clipboard)
    }

    effect(curResv, cur => handleEntryBtnUpdate(cur))
    handleEntryBtnUpdate(curResv) {
        resvType.set(": " . curResv["resvType"])
        entryBtns := [App.getCtrlByName("entry1"), App.getCtrlByName("entry2")]
        crewLastNames := curResv["crewNames"].map(name => name.split(" ")[2])

        for btn in entryBtns {
            exist := crewLastNames.has(A_Index)
            btn.Text := exist ? curResv["crewNames"][A_Index] : ""
        }
    }

    handleBookingEntry(ctrl, _) {
        if (ctrl.Text == "") {
            return
        }

        FedexBookingEntry.USE(curResv.value, ctrl.Text == "entry1" ? 1 : 2)
    }

    handleEntry(ctrl, _) {
        if (ctrl.Text == "") {
            return 
        }
        
        FedexBookingEntry.USE(curResv.value, ctrl.name == "entry1" ? 1 : 2)
    }

    onMount() {
        LV := App.getCtrlByType("ListView")
        LV.ModifyCol(1, 100)
        LV.ModifyCol(2, 200)
        try {
            curResv.set(JSON.parse(config.read("JSON")))       
        }
   
    }

    return (
        App.AddGroupBox("Section R18 w685 y+20", ""),
        App.AddText("xp15", moduleTitle),

        ; read me info
        App.AddText("xs20 y+30 h200", README),

        ; reservation info
        App.ARText("x300 y140 w200 h30", "订单详情  {1}", resvType).SetFont("s13 q5 Bold"),
        ReservationDetails(App, curResv),

        ; entry btns
        App.AddGroupBox("Section y+10 w310 r2", "录入订单"),
        App.AddButton("ventry1 xs10 w140 h40 yp+20", "").OnEvent("Click", handleEntry)
        App.AddButton("ventry2 w140 x+10 h40", "").OnEvent("Click", handleEntry),

        onMount()
    )
}