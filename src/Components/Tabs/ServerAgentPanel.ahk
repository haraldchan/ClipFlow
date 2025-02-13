#Include "../../Servers/ProfileModifyNext_Server.ahk"

ServerAgentPanel(App) {
    isListening := signal("离线")
    agent := ProfileModifyNext_Agent({
        pool: A_ScriptDir . "\src\Servers\pmn-pool",
        interval: 3000,
        expiration: 1,
        isListening: isListening
    })
    
    return (
        App.AddText("x30 y75 h40 w580", "ProfileModifyNext Server").SetFont("s15 q5"),

        ; server-side options
        ServerAgentPanel_Agent(App, config.read("agentEnabled"), agent, isListening),
        
        ; client-side options
        ServerAgentPanel_Client(App, config.read("clientEnabled"), agent)
    )
}


ServerAgentPanel_Agent(App, enabled, agent, isListening) {
    comp := Component(App, A_ThisFunc)

    onlineTextStyles := Map(
        "离线", "cRed Bold",
        "处理中...", "cBlack Norm",
        "在线", "cGreen Bold",
        "default", "cBlack Norm"
    )

    collectInterval := signal(3000)
    effect(collectInterval, cur => (agent.interval := cur))
    effect(isListening, cur => App.getCtrlByText("启动服务").Value := cur == "离线" ? false : true)

    handleConnect(connectState) {
        isListening.set(connectState ? "在线" : "离线")
        App.getCtrlByName("intervalEdit").Enabled := !connectState
    }

    comp.render := this => this.Add(
        App.AddGroupBox("Section x30 y110 w380 r5"),
        App.AddCheckBox("xs10 yp", "服务端（后台）选项")
           .OnEvent("Click", (ctrl, _) => (
                comp.disable(!ctrl.Value), 
                !ctrl.Value && isListening.set("离线")
        )),
        
        ; service activation
        App.ARCheckBox("xs20 yp+30","启动服务")
           .OnEvent("Click", (ctrl, _) => handleConnect(ctrl.Value)),
        App.AddText("x+10", "本机: " . A_ComputerName),

        ; service state
        App.AddText("xs20 h30 yp+30 0x200", "当前服务状态: "),
        App.ARText("vonlineText w250 h30 x+1 0x200", "{1}", isListening)
           .SetFont("cRed Bold")
           .SetFontStyles(onlineTextStyles),

        ; collect interval
        App.AddText("xs20 h30 yp+30 0x200", "处理请求间隔: "),
        App.AREdit("vintervalEdit w40 h25 x+1 0x200", "{1}", collectInterval)
           .OnEvent("LoseFocus", (ctrl, _) => collectInterval.set(ctrl.Value)),
        App.AddText("x+5 h30 0x200", "毫秒"),
    )

    return (comp.render(), comp.disable(!enabled))
}


ServerAgentPanel_Client(App, enabled, agent) {
    comp := Component(App, A_ThisFunc)

    connection := signal("未连接")
    statusTextStyle := Map(
        "未连接", "cBlack Norm",
        "连接中...", "cBlack Norm",
        "无响应", "cRed Bold",
        "default", "cGreen Bold"
    )

    ping(*) {
        connection.set("连接中...")
        
        res := agent.PING()
        if (!res) {
            connection.set("无响应")
            return
        } 

        connection.set(Format("在线 响应主机: {1}", res.sender))
    }

    comp.render := this => this.Add(
        App.AddGroupBox("Section x30 y260 w380 r5"),
        App.AddCheckBox((enabled ? "Checked" : "") . " xs10 yp", "客户端（前台）选项")
           .OnEvent("Click", (ctrl, _) => comp.disable(!ctrl.Value)),
        
        ; test connection
        App.ARButton("xs20 h30 yp+30", "测试连接").OnEvent("Click", ping),
        App.AddText("x+10 h30 0x200", "后台服务状态: "),
        App.ARText("vstatusText w200 h30 x+1 0x200", "{1}", connection).SetFontStyles(statusTextStyle)
    )

    return (comp.render(), comp.disable(!enabled))
}