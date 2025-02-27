BlankShareDetails(LV, selectedRooms, sendPm := false) {
    App := Gui("+AlwaysOnTop", "Share and Modify")
    App.SetFont(, "微软雅黑")

    roomCountMap := Map()
    for room in selectedRooms {
        roomCountMap[room] := (roomCountMap.has(room) ? roomCountMap[room] : 0)  + 1
    }

    db := useFileDB(config.read("dbSettings"))

    resMessage := {}
    delegateQmActions(module, cleanup := () => {}) {
        form := App.submit()
        SetTimer(() => (
            resMessage := qmAgent.delegate({
                module: module,
                form: form
            })
        ), -250)   

        return cleanup()
    }

    handleBlankShareDelegate(*) {
        if (!App.getCtrlByName("shareRoomNums").Value) {
            return 0
        }

        if (App.getCtrlByName("sendPmPost").Value) {
            SetTimer(handleTriggerPmPost, 1000)
        }

        delegateQmActions("BlankShare", () => App.Destroy())

        return 0
    }

    handleTriggerPmPost() {
        if (!resMessage.hasOwnProp("id")) {
            return
        }

        loop files (qmAgent.pool . "\*.json") {
            if (A_LoopFileName.includes(resMessage.id)) {
                if (!A_LoopFileName.includes("MODIFIED")) {
                    return
                }
            }
        }

        SetTimer(, 0)

        roomNums := App.getCtrlByName("shareRoomNums").Value
        App.getCtrlByName("shareRoomNums").Value := ""
        profiles := db.load(,, qmAgent.collectRange)
                      .filter(guest => roomNums.includes(!guest["roomNum"] ? "null" : guest["roomNum"]))

        SetTimer(() => (
            post := pmnAgent.delegate({
                rooms: roomNums.trim().split(" "),
                profiles: profiles
            })
        ), -250)
    }

    onLoad() {
        App.getCtrlByName("shareRoomNums").Value := roomCountMap.keys().join(" ")
        App.getCtrlByName("shareQty").Value := roomCountMap.values().join(" ")
        App.getCtrlByName("BlankShareAction").OnEvent("Click", handleBlankShareDelegate, -1)
    }

    props := {
        App: App,
        styles: { xPos:"x10 ", yPos: "y10 ", wide: "w350 " },
        BlankShare: {
            children: App => App.AddCheckBox((sendPm ? "Checked " : "") . "vsendPmPost h20 x+20 yp 0x200", "Share Check-in 后录入 Profile")  
        }
    }

    return (
        BlankShare(props).render(),
        onLoad(),
        App.Show()
    )
}