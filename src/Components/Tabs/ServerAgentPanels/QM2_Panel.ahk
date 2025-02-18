#Include "../../../../../QM2-for-FrontDesk/src/ActionModules/ActionModuleIndex.ahk"

QM_Panel(App, isListening) {
    qmAgent := QM2_Agent({ 
        pool: A_ScriptDir . "\src\Servers\qm-pool",
        interval: 3000,
        expiration: 1,
        collectRange: 15,
        safePost: false,
        isListening: isListening
     })

    makeShare(*) {
        form := App.getComponent("BlankShare").submit()
        form.room := App.getCtrlByName("QMRoomNum").Value
        SetTimer(() => (
            post := qmAgent.delegate({
                module: "BlankShare",
                room: String(form.room).Length < 4 ? "0" . form.room : form.room,
                shareQty: form.shareQty,
                checkIn: form.checkIn
            }),
            post.status := "已发送",
            postQueue.set(queue => queue.unshift(post))
        ), -250)
    }
    
    overrideActions() {
        App.getCtrlByName("BlankShareAction").OnEvent("Click", makeShare)
    }

    return (
        App.AddGroupBox("Section w200 r30", "QM2 Server").SetFont("s12 Bold"),
        App.AddText("yp+30 h30 0x200", "指定房号："),
        App.AddEdit("vQMRoomNum x+1 h30", ""),

        ; QM BlankShare
        BlankShare({ App: App, styles: { xPos:"xs10", yPos: "yp+03", wide: "w190" } }),

        ; override action events
        overrideActions()
    )
}