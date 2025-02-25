#Include "./PostDetails.ahk"

ServerAgentPanel_Client(App, enabled, agent) {
    comp := Component(App, A_ThisFunc)

    global postQueue := signal([{ status: "", id: "" }])

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
        
        res := agent.PING()
        if (!res) {
            connection.set("无响应")
        } else {
            connection.set(Format("在线 {1}", res.sender))
        }
        
        ctrl.Enabled := true
    }

    handlePostUpdate(*) {
        ownPosts := []
        
        loop files (agent.pool . "\*.json") {
            if (InStr(A_LoopFileName, A_ComputerName)) {
                status := StrSplit(A_LoopFileName, "==")[1]
                post := JSON.parse(FileRead(A_LoopFileFullPath, "UTF-8"))
                post["status"] := postStatus[status]
                ownPosts.InsertAt(1, post)
            }
        }

        if (ownPosts.Length > 0) {
            postQueue.set(ownPosts)
        }
    }

    lvSettings := {
        columnDetails: {
            keys: ["status","id"],
            titles: ["当前状态", "POST ID"],
            widths: [60, 168]
        },
        options: {
            lvOptions: "Grid NoSortHdr -Multi LV0x4000 w260 r8 xs20 yp+25",
            itemOptions: ""
        }
    }

    showPostDetails(LV, row, *) {
        if (row == 0) {
            return
        }

        selectedPost := postQueue.value.find(post => post["id"] == LV.GetText(row, 2))
        if (!selectedPost.has("content")) {
            return 
        }
        PostDetails(selectedPost)
    }

    comp.render := this => this.Add(
        App.AddGroupBox("Section x30 y260 w300 r12"),
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