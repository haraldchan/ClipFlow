#Include "../../../../../QM2-for-FrontDesk/src/ActionModules/ActionModuleIndex.ahk"

QM2_Panel(props) {
    App := Gui("+AlwaysOnTop", "ServerAgents - QM2 Agent")
    App.SetFont(, "微软雅黑")


    p := useProps(props, {
        sendPm: true,
        selectedGuests: []
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

    effect(selectedModule, handleModuleChange)
    handleModuleChange(moduleName) {
        for module in modules {
            App.getCtrlByName(module.name . "Action").Opt(module.name = moduleName ? "+Default" : "-Default")
        }
    }

    resMessage := {}
    form := {}
    delegateQmActions(module) {
        form := App.Submit()
        SetTimer(() => (
            resMessage := agent.delegate({
                module: module,
                form: form,
                profiles: p.selectedGuests
            })
        ), -250)

        SetTimer((*) => (App.Destroy(), WinHide(popupTitle)), -100)

        return 0
    }

    handleBlankShareDelegate(*) {
        if (!App.getCtrlByName("shareRoomNums").Value) {
            return 0
        }

        if (App.getCtrlByName("sendPmPost").Value) {
            SetTimer(handleTriggerPmPost, 1000)
        }

        return delegateQmActions("BlankShare")
    }

    db := useFileDB(config.read("dbSettings"))
    handleTriggerPmPost() {
        if (!resMessage.hasOwnProp("id")) {
            return
        } else if (resMessage.HasOwnProp("status") && resMessage.status == "failed") {
            SetTimer(, 0)
            return
        }

        loop files (agent.qmPool . "\*.json") {
            if (A_LoopFileName.includes(resMessage.id)) {
                if (!A_LoopFileName.includes("MODIFIED")) {
                    return
                }
            }
        }

        SetTimer(, 0)

        roomNums := form.shareRoomNums.trim()
        ; selectedGuests can only pass by GuestProfileList
        ; if no selectedGuest, then filter results in db by room number(request from ServerAgent_Panel)
        profiles := p.selectedGuests.Length == 0
            ? db.load(,, agent.collectRange).filter(guest => roomNums.includes(!guest["roomNum"] ? "null" : guest["roomNum"]))
            : p.selectedGuests

        SetTimer(() => (
            post := agent.delegate({
                rooms: roomNums.split(" "),
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

    onMount() {
        roomCountMap := Map()
        for roomProfiles in p.selectedGuests {
            for roomNum, profiles in roomProfiles {
                roomCountMap[roomNum] := profiles.Length - 1
            }
        }

        shareRoomNums := App.getCtrlByName("shareRoomNums")
        shareRoomNums.Enabled := false
        shareRoomNums.Value := roomCountMap.keys().join(" ")
        App.getCtrlByName("shareQty").Value := roomCountMap.values().join(" ")

        ; re-label btns
        BlankShareAction := App.getCtrlByName("BlankShareAction")
        BlankShareAction.Text := "Share 代行"
        BlankShareAction.Opt("+Default")

        ; override events
        BlankShareAction.OnEvent("Click", handleBlankShareDelegate, -1)
        App.getCtrlByName("PaymentRelationAction").OnEvent("Click", handlePaymentRelationDelegate, -1)
    }


    return (
        ; GroupBox frame
        App.AddGroupBox("Section w370 h300 x10 y10", "QM2 Agent").SetFont("s12 Bold"),

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
                    xPos: "x20 ",
                    yPos: "y110 ",
                    rPanelXPos: "x200 ",
                    wide: "w350 ",
                    useCopyBtn: false
                },
                BlankShare: {
                    children: App => App.AddCheckBox((p.sendPm ? "Checked " : "") . "vsendPmPost h20 x+20 yp 0x200", "Share Check-in 后录入 Profile")
                }
            }
        ),
        ; initializing
        onMount(),
        App.Show()
    )
}