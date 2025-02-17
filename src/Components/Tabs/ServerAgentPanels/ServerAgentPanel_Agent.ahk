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

    handleConnect(ctrl, _) {
        if (MsgBox("服务将启动，请确保 Opera 处于 InHouse 界面", "Server Agent", "OKCancel") == "Cancel") {
            return
        }

        isListening.set(ctrl.Value ? "在线" : "离线")
        App.getCtrlByName("intervalEdit").Enabled := !ctrl.Value
    }

    comp.render := this => this.Add(
        App.AddGroupBox("Section x30 y110 w380 r5"),
        App.AddCheckBox("xs10 yp", "服务端（后台）选项")
           .OnEvent("Click", (ctrl, _) => (
                comp.disable(!ctrl.Value), 
                config.write("agentEnabled", ctrl.Value)
                !ctrl.Value && isListening.set("离线"),
        )),
        
        ; service activation
        App.ARCheckBox("xs20 yp+30","启动服务").OnEvent("Click", handleConnect),
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

    return (
        comp.render(), 
        comp.disable(!enabled)
    )
}