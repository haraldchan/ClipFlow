#Include "../../../../../QM2-for-FrontDesk/src/ActionModules/ActionModuleIndex.ahk"

QM2_Panel(props) {
    isPopup := !props.hasOwnProp("App")
    if (isPopup) {
        App := Gui("+AlwaysOnTop", "ServerAgents - QM2 Agent")
        App.SetFont(, "微软雅黑")
    } else {
        App := props.App
    }

    p := useProps(props, {
        sendPm: true,
        selectedRooms: []
    })
    
    modules := OrderedMap(
        BlankShare, "生成空白(NRR) Share",
        PaymentRelation, "生成 PayBy PayFor 信息"
    )
    selectedModule := signal(modules.keys()[1].name)
    moduleComponents := OrderedMap()
    for module in modules {
        moduleComponents[module.name] := module
    }
    
    db := useFileDB(config.read("dbSettings"))

    resMessage := {}
    form := {}
    delegateQmActions(module, cleanup := () => {}) {
        form := App.getComponent(module).submit()
        SetTimer(() => (
            resMessage := qmAgent.delegate({
                module: module,
                form: form
            })
        ), -250)

        return isPopup ? App.Destroy() : cleanup()
    }

    handleBlankShareDelegate(*) {
        if (!App.getCtrlByName("shareRoomNums").Value) {
            return 0
        }

        if (App.getCtrlByName("sendPmPost").Value) {
            SetTimer(handleTriggerPmPost, 1000)
        }

        delegateQmActions("BlankShare", () => (
            App.getCtrlByName("shareRoomNums").Value := "",
            App.getCtrlByName("shareQty").Value := 1,
            App.getCtrlByName("checkIn").Value := true,
            App.getCtrlByName("sendPmPost").Value := false
        ))

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

        roomNums := form.shareRoomNums
        profiles := db.load(,, isPopup ? 480 : qmAgent.collectRange)
                      .filter(guest => roomNums.includes(!guest["roomNum"] ? "null" : guest["roomNum"]))

        SetTimer(() => (
            post := pmnAgent.delegate({
                rooms: roomNums.trim().split(" "),
                profiles: profiles
            })
        ), -250)
    }

    handlePaymentRelationDelegate(*) {
        if (!App.getCtrlByName("pfRoom").Value || !App.getCtrlByName("pfName").Value) {
            return 0
        }

        return delegateQmActions("PaymentRelation")
    }

    onLoad() {
        ; initialize BlankShare values
        roomCountMap := Map()
        for room in p.selectedRooms {
            roomCountMap[room] := (roomCountMap.has(room) ? roomCountMap[room] : -1) + 1
        }
        App.getCtrlByName("shareRoomNums").Value := roomCountMap.keys().join(" ")
        App.getCtrlByName("shareQty").Value := roomCountMap.values().join(" ")
        
        ; re-label btns
        App.getCtrlByName("BlankShareAction").Text := "Share 代行"

        ; override actions
        App.getCtrlByName("BlankShareAction").OnEvent("Click", handleBlankShareDelegate, -1)
        App.getCtrlByName("PaymentRelationAction").OnEvent("Click", handlePaymentRelationDelegate, -1)
    }


    return (
        ; GroupBox frame
        App.AddGroupBox("Section w370" . (isPopup ? "h464 x340 y108" : "h300 x10 y10"), "QM2 Agent")
           .SetFont("s12 Bold"),
        
        ; QM modules
        modules.keys().map(module =>
            App.AddRadio(A_Index == 1 ? "Checked xs10 yp+30 h20" : "xs10 yp+30 h20", modules[module])
            .OnEvent("Click", (*) => selectedModule.set(module.name))
        ),
        Dynamic(
            selectedModule,
            moduleComponents, {
                App: App,
                styles: { 
                    xPos: isPopup ? "x10 " : "x350 ", 
                    yPos: isPopup ? "y150 " : "y200 ", 
                    rPanelXPos: isPopup ? "x170 " : "x530 ", 
                    wide: "w350 ", 
                    useCopyBtn: false 
                },
                BlankShare: {
                    children: App => App.AddCheckBox((p.sendPm ? "Checked " : "") . "vsendPmPost h20 x+20 yp 0x200", "Share Check-in 后录入 Profile")
                }
            }
        ),

        ; initializing
        onLoad(),
        isPopup ? App.Show() : 0
    )
}