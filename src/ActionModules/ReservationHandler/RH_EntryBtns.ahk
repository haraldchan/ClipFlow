RH_EntryBtns(App, curResv, resvSource) {
    effect(curResv, cur => handleEntryBtnUpdate(cur))
    handleEntryBtnUpdate(curResv) {
        entryBtns := [App.getCtrlByName("entry1"), App.getCtrlByName("entry2")]
        
        if (curResv["agent"] == "fedex") {
            resvSource.set(": " . curResv["resvType"])
            crewLastNames := curResv["crewNames"].map(name => name.split(" ")[2])
            
            for btn in entryBtns {
                exist := crewLastNames.has(A_Index)
                btn.Text := exist ? curResv["crewNames"][A_Index] : ""
            }

            return
        }

        resvSource.set(Format(": {1} - {2}", curResv["agent"].toTitle(), curResv["orderId"]))
        entryBtns[1] := "录入订单"
        entryBtns[2] := curResv["roomQty"].Length > 1 ? "录入整个 Party " : ""
    }

    handleEntry(ctrl, _) {
        if (!ctrl.Text) {
            return
        }

        if (curResv["agent"] == "fedex") {
            FedexBookingEntry.USE(curResv.value, ctrl.name == "entry1" ? 1 : 2)
        } else {
            RH_OTA.USE(curResv.value, ctrl.name == "entry2" ? true : false )
        }
    }

    return (
        App.AddGroupBox("Section y+10 w310 r2 ", "录入订单"),
        App.AddButton("ventry1 xs10 w140 h40 yp+20", "").OnEvent("Click", handleEntry),
        App.AddButton("ventry2 w140 x+10 h40", "").OnEvent("Click", handleEntry),
    )
}
