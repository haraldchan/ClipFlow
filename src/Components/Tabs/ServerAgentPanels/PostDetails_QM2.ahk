PostDetails_QM2(post, moduleName, props) {
    App := Gui(, "Post Details - " . post["id"])
    App.SetFont(, "微软雅黑")
    App.OnEvent("Close", (*) => App.Destroy())
    props.App := App

    qmModules := Map(
        "BlankShare",      { desc:"Share 详情", module: BlankShare },
        "PaymentRelation", { desc: "Payment 关系", module: PaymentRelation }
    )

    handleRepost(*) {
        form := App.Submit()
        SetTimer(() => (
            ; qmAgent.delegate({
            agent.delegate({
                module: moduleName,
                form: form,
                profiles: post["content"]["profiles"]
            }),
            renameResendPost(post["id"])
        ), -250)

        App.Destroy()

        return 0
    }

    renameResendPost(id) {
        ; loop files (qmAgent.pool . "\*.json") {
        loop files (agent.qmPool . "\*.json") {
            if (InStr(A_LoopFileFullPath, id)) {
                status := StrSplit(A_LoopFileName, "==")[1]
                FileMove(A_LoopFileFullPath, StrReplace(A_LoopFileFullPath, status, "RESENT"))
                break
            }
        }
    }

    onMount() {
        App.getCtrlByName(moduleName . "Action").OnEvent("Click", handleRepost, -1)
        App.getCtrlByName(moduleName . "Action").Opt("+Default")
    }

    return (
        App.AddGroupBox("Section w370 r12", "代行详情").SetFont("Bold"),
        App.AddText("xs10 yp+20", "发送状态: " . post["status"]),
        App.AddText("xs10 yp+20", "发送时间: " . post["time"]),
        App.AddText("xs10 w200 h35 yp+30" , qmModules[moduleName].desc).SetFont("Bold s10"),
        
        qmModules[moduleName].module.Call(props).render(),

        onMount(),
        App.Show()
    )
}