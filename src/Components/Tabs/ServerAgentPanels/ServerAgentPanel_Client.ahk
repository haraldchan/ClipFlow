ServerAgentPanel_Client(App, enabled, agent) {
    comp := Component(App, A_ThisFunc)

    global postQueue := signal([])
    effect(postQueue, cur => cur.Length > 10 && postQueue.set(cur.slice(1,11)))
    postStatusMap := Map(
        "PENDING", "已发送",
        "COLLECTED", "处理中",
        "MODIFIED", "已完成",
        "ABORTED", "错误终止"
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
            connection.set(Format("在线 响应主机: {1}", res.sender))
        }
        
        ctrl.Enabled := true
    }

    handlePostQueueUpdate(*) {
        for post in postQueue.value {
            loop files (agent.pool . "\*.json") {
                if (InStr(A_LoopFileName, post["id"])) {
                    newPost := post.deepClone()
                    newPost["status"] := postStatusMap[StrSplit(A_LoopFileName, "==")[1]]
                    postQueue.update(A_Index, newPost)
                }
            } 
        }
    }

    lvSettings := {
        columnDetails: {
            keys: ["status","id"],
            titles: ["当前状态", "POST ID"],
            widths: [60, 260]
        },
        options: {
            lvOptions: "Grid -ReadOnly -Multi LV0x4000 w330 r8 xs20 yp+25",
            itemOptions: ""
        }
    }

    comp.render := this => this.Add(
        App.AddGroupBox("Section x30 y260 w380 r12"),
        App.AddCheckBox((enabled ? "Checked" : "") . " xs10 yp", "客户端（前台）选项")
           .OnEvent("Click", (ctrl, _) => comp.disable(!ctrl.Value)),
        
        ; test connection
        App.ARButton("xs20 w60 h30 yp+30", "测试连接").OnEvent("Click", ping),
        App.AddText("x+10 h30 0x200", "后台服务状态: "),
        App.ARText("vstatusText w200 h25 x+1 0x200", "{1}", connection).SetFontStyles(statusTextStyle),

        ; post status list
        App.AddText("xs20 yp+50 h20 0x200", "已发送代行状态").SetFont("Bold"),
        App.ARButton("x+5 h20 w20 +Center", "↻")
           .OnEvent("Click", handlePostQueueUpdate)
           .SetFont("Bold"),
        App.ARListView(lvSettings.options, lvSettings.columnDetails, postQueue)
        ;    .OnEvent("ContextMenu", PostDetail)
    )

    return (comp.render(), comp.disable(!enabled))
}