ServerAgentPanel_Client(App, enabled, agent) {
    comp := Component(App, A_ThisFunc)

    global postQueue := signal([])
    effect(postQueue, cur => cur.Length > 10 && postQueue.set(cur.slice(1,11)))
    handlePostQueueUpdate(cur) {
        if (cur.Length > 10) {
            postQueue.set(cur.slice(1,11))
        }
    }

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
            return
        } else {
            connection.set(Format("在线 响应主机: {1}", res.sender))
        }
        
        ctrl.Enabled := true
    }

    columnDetails := {
        keys: ["status","id", ],
        titles: ["当前状态", "POST ID"],
        widths: [60, 90]
    }

    options := {
        lvOptions: "Grid Checked -ReadOnly -Multi LV0x4000 w300 r5 xs20",
        itemOptions: ""
    }

    comp.render := this => this.Add(
        App.AddGroupBox("Section x30 y260 w380 r8"),
        App.AddCheckBox((enabled ? "Checked" : "") . " xs10 yp", "客户端（前台）选项")
           .OnEvent("Click", (ctrl, _) => comp.disable(!ctrl.Value)),
        
        ; test connection
        App.ARButton("xs20 h30 yp+30", "测试连接").OnEvent("Click", ping),
        App.AddText("x+10 h30 0x200", "后台服务状态: "),
        App.ARText("vstatusText w200 h30 x+1 0x200", "{1}", connection).SetFontStyles(statusTextStyle),

        ; post status list
        App.ARListView(options, columnDetails, postQueue)
        ;    .OnEvent("ContextMenu", PostDetail)
    )

    return (comp.render(), comp.disable(!enabled))
}