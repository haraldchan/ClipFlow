PostDetails_PaymentRelation(post) {
    App := Gui(, "Post Details - " . post["id"])
    App.SetFont(, "微软雅黑")
    App.OnEvent("Close", (*) => App.Destroy())

    form := post["content"]["form"]

    handleRepost(*) {
        form := App.Submit()
        SetTimer(() => (
            qmAgent.delegate({
                module: "PaymentRelation",
                form: form
            }),
            renameResendPost(post["id"])
        ), -250)

        App.Destroy()

        return 0
    }

    renameResendPost(id) {
        loop files (qmAgent.pool . "\*.json") {
            if (InStr(A_LoopFileFullPath, id)) {
                status := StrSplit(A_LoopFileName, "==")[1]
                FileMove(A_LoopFileFullPath, StrReplace(A_LoopFileFullPath, status, "RESENT"))
                break
            }
        }
    }

    onMount() {
        App.getCtrlByName("PaymentRelationAction").OnEvent("Click", handleRepost, -1)
    }

    return (
        App.AddGroupBox("Section w370 r12", "代行详情").SetFont("Bold"),
        App.AddText("xs10 yp+20", "发送状态: " . post["status"]),
        App.AddText("xs10 yp+20", "发送时间: " . post["time"]),
        App.AddText("xs10 w200 h35 yp+30" , "Payment 关系").SetFont("Bold s10"),
        
        ; post guest list
        PaymentRelation({ 
            App: App,
            styles: {
                useCopyBtn: false,
                xPos: "x20 ",
                yPos: "y110 ",
                wide: "w350 ",
                panelWide: "w170 ",
                rPanelXPos: "x200 "
            },
            pfRoom: form["pfRoom"],
            pfName: form["pfName"],
            party:  form["party"],
            partyRoomQty: form["partyRoomQty"],
            pbRoom: form["pbRoom"],
            pbName: form["pbName"]
        }).render(),

        onMount(),
        App.Show()
    )
}