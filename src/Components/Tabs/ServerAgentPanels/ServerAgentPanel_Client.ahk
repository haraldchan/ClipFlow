#Include "./PostDetails_Profile.ahk"
#Include "./PostDetails_PaymentRelation.ahk"

ServerAgentPanel_Client(App, enabled) {
    comp := Component(App, A_ThisFunc)

    postQueue := signal([{ status: "", time: "", id: "" }])
    
    postStatus := Map(
        "PENDING", "已发送",
        "COLLECTED", "处理中",
        "MODIFIED", "已完成",
        "ABORTED", "错误终止",
        "RESENT", "已重发",
        "ABANDONED", "超时弃用",
        "PING", "连接中",
        "ONLINE", "已连接"
    )

    connection := signal("未连接")
    statusTextStyle := Map(
        "未连接", "cBlack Norm",
        "连接中...", "cBlack Norm",
        "无响应", "cRed Bold",
        "default", "cGreen Bold"
    )

    ping(ctrl, _) {
        connection.set("连接中...")
        ctrl.Enabled := false
        
        res := pmnAgent.PING()
        if (!res) {
            connection.set("无响应")
        } else {
            connection.set(Format("在线 {1}", res.sender))
        }
        
        ctrl.Enabled := true
    }

    handlePostUpdate(*) {
        ownPosts := []
        
        ; check pmn posts
        loop files (pmnAgent.pool . "\*.json") {
            if (InStr(A_LoopFileName, A_ComputerName)) {
                status := StrSplit(A_LoopFileName, "==")[1]
                post := JSON.parse(FileRead(A_LoopFileFullPath, "UTF-8"))
                post["status"] := postStatus[status]
                post["time"] := FormatTime(post["id"].substr(1, 14), "yyyy/MM/dd HH:mm")
                post["action"] := "Profile"
                ownPosts.InsertAt(1, post)
            }
        }

        ; check qm posts
        loop files (qmAgent.pool . "\*.json") {
            if (InStr(A_LoopFileName, A_ComputerName)) {
                status := StrSplit(A_LoopFileName, "==")[1]
                post := JSON.parse(FileRead(A_LoopFileFullPath, "UTF-8"))
                post["status"] := postStatus[status]
                post["time"] := FormatTime(post["id"].substr(1, 14), "yyyy/MM/dd HH:mm")
                post["action"] := post["content"]["module"] == "BlankShare" ? "Share" : "PayBy PayFor"
                ownPosts.InsertAt(1, post)
            }
        }     

        if (ownPosts.Length > 0) {
            postQueue.set(ownPosts)
            App.getCtrlByName("postList").ModifyCol(3, "SortDesc")
        }
    }

    lvSettings := {
        columnDetails: {
            keys: ["status", "action", "time", "id"],
            titles: ["当前状态", "代行类型", "发送时间", "POST ID"],
            widths: [60, 100, 150, 170]
        },
        options: {
            lvOptions: "vpostList Grid -Multi LV0x4000 w320 r14 xs20 yp+25",
            itemOptions: ""
        }
    }

    showPostDetails(LV, row, *) {
        if (row == 0 || row > 10000) {
            return
        }

        selectedPost := postQueue.value.find(post => post["id"] == LV.GetText(row, 4))

        switch selectedPost["action"] {
            case "Profile":
                PostDetails_Profile(selectedPost)
            case "PayBy PayFor":
                PostDetails_PaymentRelation(selectedPost)
        }
    }

    comp.render := this => this.Add(
        App.AddGroupBox("Section x350 y110 w350 r18"),
        App.AddCheckBox((enabled ? "Checked" : "") . " xs10 yp", "客户端（前台）选项")
           .OnEvent("Click", (ctrl, _) => (comp.disable(!ctrl.Value), config.write("clientEnabled", ctrl.Value))),
        
        ; test connection
        App.ARButton("xs20 w60 h30 yp+30", "测试连接").OnEvent("Click", ping),
        App.AddText("x+5 h30 0x200", "服务状态: "),
        App.ARText("vstatusText w150 h30 x+1 0x200", "{1}", connection).SetFontStyles(statusTextStyle),

        ; post status list
        App.AddText("xs20 yp+50 h20 0x200", "已发送代行状态").SetFont("Bold"),
        App.ARButton("x+5 h20 w20 +Center", "↻")
           .OnEvent("Click", handlePostUpdate)
           .SetFont("Bold"),
        App.ARListView(lvSettings.options, lvSettings.columnDetails, postQueue)
           .OnEvent("ContextMenu", showPostDetails)
    )

    return (
        comp.render(), 
        comp.disable(!enabled),
        handlePostUpdate()
    )
}