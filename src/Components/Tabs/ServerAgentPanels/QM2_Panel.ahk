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

    form := {}
    delegateQmActions(module) {
        form := App.Submit()
        agent.delegate({
            module: module,
            form: form,
            profiles: p.selectedGuests
        })

        return 0
    }

    
    handleBlankShareDelegate(*) {
        if (!App["shareRoomNums"].Value) {
            return 0
        }

        delegateQmActions("BlankShare")

        if (App["sendPmPost"].Value) {
            handleTriggerPmPost()
        }

        SetTimer((*) => (App.Destroy(), WinHide(popupTitle)), -100)

        return 0
    }

    db := useFileDB(config.read("dbSettings"))
    handleTriggerPmPost() {
        roomNums := form.shareRoomNums.trim()
        profiles := p.selectedGuests.Length == 0
            ? db.load(,, agent.collectRange).filter(guest => roomNums.includes(!guest["roomNum"] ? "null" : guest["roomNum"]))
            : p.selectedGuests

        SetTimer(() => (
            post := agent.delegate({
                rooms: roomNums.split(" "),
                profiles: profiles
            })
        ), -300)
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

        shareRoomNums := App["shareRoomNums"]
        shareRoomNums.Enabled := false
        shareRoomNums.Value := roomCountMap.keys().join(" ")
        App["shareQty"].Value := roomCountMap.values().join(" ")

        ; re-label btns
        BlankShareAction := App["BlankShareAction"]
        BlankShareAction.Text := "Share 代行"
        BlankShareAction.Opt("+Default")

        ; override events
        BlankShareAction.OnEvent("Click", handleBlankShareDelegate, -1)
        App["PaymentRelationAction"].OnEvent("Click", handlePaymentRelationDelegate, -1)
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
