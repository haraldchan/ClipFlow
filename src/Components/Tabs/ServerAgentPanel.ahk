#Include "../../Servers/ProfileModifyNext_Server.ahk"

ServerAgentPanel(App) {

    return (
        App.AddText("x30 y75 h40 w580", "ProfileModifyNext  Server").SetFont("s15 q5"),

        ; server-side options
        ServerAgentPanel_Agent(App),
        
        ; client-side options
        ServerAgentPanel_Client(App)
    )
}


ServerAgentPanel_Client(App) {
    comp := Component(App, A_ThisFunc)

    client := ProfileModifyNext_Client({ pool: A_ScriptDir . "\src\Servers\pmn-pool" })

    connection := signal("未连接")
    effect(connection, status => handleConnectionStatusTextStyle(status))
    handleConnectionStatusTextStyle(status) {
        statusText := App.getCtrlByName("statusText")
        if (status == "未连接" || status == "连接中...") {
            statusText.SetFont("cBlack Norm")
        } else if (status == "无响应...") {
            statusText.SetFont("cRed Bold")
        } else {
            statusText.SetFont("cGreen Bold")
        }        
    }

    ping(*) {
        statusText := App.getCtrlByName("statusText")
        res := client.PING(connection)
        if (!res) {
            connection.set("无响应...")
            return
        } 

        connection.set(Format("在线 响应主机: {1}", res.sender))
    }

    comp.render := this => this.Add(
        App.AddGroupBox("Section x30 y260 w380 r5"),
        App.AddCheckBox("Checked xs10 yp", "客户端（前台）选项")
           .OnEvent("Click", (ctrl, _) => comp.disable(!ctrl.Value)),
        
        ; test connection
        App.ARButton("xs20 h30 yp+30", "测试连接").OnEvent("Click", ping),
        App.AddText("x+10 h30 0x200", "后台服务状态: "),
        App.ARText("vstatusText w200 h30 x+1 0x200", "{1}", connection)
    )

    return comp.render()
}


ServerAgentPanel_Agent(App) {
    comp := Component(App, A_ThisFunc)

    isListening := signal("离线")
    effect(isListening, cur => handleOnlineTextStyle(cur))
    handleOnlineTextStyle(state) {
        onelineText := App.getCtrlByName("onlineText")
        if (state == "处理中...") {
            onelineText.SetFont("cBlack Bold")
        } else if (state == "离线") {
            onelineText.SetFont("cRed Bold")
        } else {
            onelineText.SetFont("cGreen Bold")
        }        
    }

    collectInterval := signal(3000)
    effect(collectInterval, cur => (agent.interval := cur))

    agent := ProfileModifyNext_Agent({
        pool: A_ScriptDir . "\src\Servers\pmn-pool",
        interval: 3000,
        expiration: 1,
        isListening: isListening
    })

    comp.render := this => this.Add(
        App.AddGroupBox("Section x30 y110 w380 r5"),
        App.AddCheckBox("Checked xs10 yp ", "服务端（后台）选项")
           .OnEvent("Click", (ctrl, _) => comp.disable(!ctrl.Value)),
        
        ; service activation
        App.ARCheckBox("xs20 yp+30","启动服务")
           .OnEvent("Click", (ctrl, _) => isListening.set(ctrl.Value == true ? "在线" : "离线")),
        App.AddText("x+10", "本机: " . A_ComputerName),

        ; service state
        App.AddText("xs20 h30 yp+30 0x200", "当前服务状态: "),
        App.ARText("vonlineText w250 h30 x+1 0x200", "{1}", isListening).SetFont("cRed Bold"),

        ; collect interval
        App.AddText("xs20 h30 yp+30 0x200", "处理请求间隔: "),
        App.AREdit("w40 h25 x+1 0x200", "{1}", collectInterval)
           .OnEvent("LoseFocus", (ctrl, _) => collectInterval.set(ctrl.Value)),
        App.AddText("x+5 h30 0x200", "毫秒"),
    )

    return comp.render()
}