PostDetails_QM2(post, moduleName, props) {
    App := Gui(, "Post Details - " . post["id"])
    App.SetFont(, "微软雅黑")
    App.OnEvent("Close", (*) => App.Destroy())
    props.App := App

    qmModules := Map(
        "BlankShare",      { desc: "Share 详情", module: BlankShare },
        "PaymentRelation", { desc: "Payment 关系", module: PaymentRelation }
    )

    resMessage := {}
    form := {}
    handleRepost(*) {
        form := App.Submit()
        SetTimer(() => (
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
        loop files (agent.qmPool . "\*.json") {
            if (InStr(A_LoopFileFullPath, id)) {
                status := StrSplit(A_LoopFileName, "==")[1]
                FileMove(A_LoopFileFullPath, StrReplace(A_LoopFileFullPath, status, "RESENT"))
                break
            }
        }
    }

    handleBlankShareDelegate(*) {
        if (!App["shareRoomNums"].Value) {
            return 0
        }

        if (App["sendPmPost"].Value) {
            SetTimer(handleTriggerPmPost, 1000)
        }

        return handleRepost()
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
        profiles := post["content"]["profiles"].Length == 0
            ? db.load(, , agent.collectRange).filter(guest => roomNums.includes(!guest["roomNum"] ? "null" : guest["roomNum"]))
            : post["content"]["profiles"]

        SetTimer(() => (
            post := agent.delegate({
                rooms: roomNums.split(" "),
                profiles: profiles
            })
        ), -250)
    }

    onMount() {
        App[moduleName . "Action"].OnEvent("Click", handleBlankShareDelegate, -1)
        App[moduleName . "Action"].Opt("+Default")
    }

    return (
        App.AddGroupBox("Section w370 r12", "代行详情").SetFont("Bold"),
        App.AddText("xs10 yp+20", "发送状态: " . post["status"]),
        App.AddText("xs10 yp+20", "发送时间: " . post["time"]),
        App.AddText("xs10 w200 h35 yp+30", qmModules[moduleName].desc).SetFont("Bold s10"),
        qmModules[moduleName].module.Call(props).render(),
        onMount(),
        App.Show()
    )
}