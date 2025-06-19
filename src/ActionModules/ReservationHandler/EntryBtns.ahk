EntryBtns(App, curResv, resvSource) {
    effect(curResv, handleEntryBtnUpdate)
    handleEntryBtnUpdate(cur) {
        entryBtns := [App.getCtrlByName("entry1"), App.getCtrlByName("entry2")]

        if (cur["agent"] == "fedex") {
            resvSource.set("FEDEX: " . cur["resvType"])
            crewLastNames := cur["crewNames"].map(name => name.split(" ")[2])

            for btn in entryBtns {
                exist := crewLastNames.has(A_Index)
                btn.Text := exist ? cur["crewNames"][A_Index] : ""
            }

            return
        }

        resvSource.set(Format(": {1} - {2}", cur["agent"].toTitle(), cur["orderId"]))
        entryBtns[1].Text := "录入订单"
        entryBtns[2].Text := cur["roomQty"] > 1 ? "录入整个 Party " : ""
    }

    handleEntry(ctrl, _) {
        if (!ctrl.Text) {
            return
        }

        if (curResv.value["agent"] == "fedex") {
            FedexBookingEntry.USE(curResv.value, ctrl.name == "entry1" ? 1 : 2)
        } else {
            RH_OTA.USE(
                curResv.value,
                ctrl.name == "entry2" ? true : false,
                App["withRemarks"].Value,
                App["packages"].Value.trim()
            )

            App["withRemarks"].Value := false
            App["packages"].Value := ""
        }
    }

    return (
        App.AddGroupBox("Section y+10 w310 r2 ", "录入订单"),
        App.AddButton("ventry1 xs10 w140 h40 yp+20", "").OnEvent("Click", handleEntry),
        App.AddButton("ventry2 w140 x+10 h40", "").OnEvent("Click", handleEntry)
    )
}
