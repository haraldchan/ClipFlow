#Include "../../../../../QM2-for-FrontDesk/src/ActionModules/ActionModuleIndex.ahk"

QM2_Panel(App, isListening) {
    qmAgent := QM2_Agent({ 
        pool: A_ScriptDir . "\src\Servers\qm-pool",
        interval: 3000,
        expiration: 1,
        collectRange: 15,
        safePost: false,
        isListening: isListening
     })

    modules := OrderedMap(
        BlankShare,       "生成空白(NRR) Share",
        PaymentRelation,  "生成 PayBy PayFor 信息"
    )
    selectedModule := signal(modules.keys()[1].name)
    moduleComponents := OrderedMap()
    for module in modules {
        moduleComponents[module.name] := module
    }

    db := useFileDB(config.read("dbSettings"))

    resMessage := {}
    delegateQmActions(module, cleanup := () => {}) {
        qmSent := App.getCtrlByName("qmSent")
        qmSent.visible := true
        SetTimer(() => qmSent.visible := false, -2000)

        form := App.getComponent(module).submit()
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

        isSendPmPost := App.getCtrlByName("sendPmPost").Value
         delegateQmActions("BlankShare", () => (
            !isSendPmPost && App.getCtrlByName("shareRoomNums").Value := "",
            App.getCtrlByName("checkIn").Value := 1,
            App.getCtrlByName("shareQty").Value := 1
        ))

        if (isSendPmPost) {
            SetTimer(handleTriggerPmPost, 1000)
        }

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
        profiles := db.load(,, 480)
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
        App.getCtrlByName("BlankShareAction").OnEvent("Click", handleBlankShareDelegate, -1)
        App.getCtrlByName("PaymentRelationAction").OnEvent("Click", handlePaymentRelationDelegate, -1)
    }


    return (
        App.AddGroupBox("Section w370 h464 x340 y108", "QM2 Agent").SetFont("s12 Bold"),
        App.AddText("vqmSent Hidden xs120 yp+2", "代行任务已发送！").SetFont("cGreen Bold"),
        modules.keys().map(module =>
            App.AddRadio(A_Index == 1 ? "Checked xs10 yp+30 h20" : "xs10 yp+30 h20", modules[module])
               .OnEvent("Click", (*) => selectedModule.set(module.name))
        ),
        Dynamic(
            selectedModule, 
            moduleComponents, 
            { 
                App: App, 
                styles: { xPos:"x350 ", yPos: "y200 ", wide: "w350 ", rPanelXPos: "x530 ", useCopyBtn: false },
                BlankShare: { children: App => App.AddCheckBox("vsendPmPost h20 x+20 yp 0x200", "Share Check-in 后录入 Profile") } 
            }
        ),

        ; override action events
        onLoad()
    )
}