ServerAgentPanel_Agent(App, enabled, isListening) {
    comp := Component(App, A_ThisFunc)

    onlineTextStyles := Map(
        "离线", "cRed Bold",
        "处理中...", "cBlack Norm",
        "在线", "cGreen Bold",
    ).Default("cBlack Norm")

    collectInterval := signal(agent.interval)
    effect(collectInterval, cur => (agent.interval := cur))
    effect(isListening, cur => App.getCtrlByName("serviceActivator").Value := cur == "离线" ? false : true)

    handleConnect(ctrl, _) {
        if (MsgBox("服务将启动，请确保 Opera 处于 InHouse 界面", "Server Agent", "4096 OKCancel") == "Cancel") {
            ctrl.Value := false
            return
        }

        isListening.set(ctrl.Value ? "在线" : "离线")
        App["intervalEdit"].Enabled := !ctrl.Value
    }

    comp.render := this => this.Add(
        App.AddGroupBox("Section x30 y110 w300 r5"),
        App.AddCheckBox((enabled ? "Checked" : "") . " xs10 yp", "服务端（后台）选项")
           .OnEvent("Click", (ctrl, _) => (
                comp.disable(!ctrl.Value), 
                config.write("agentEnabled", ctrl.Value),
                !ctrl.Value && isListening.set("离线")
        )),
        
        ; service activation
        App.ARCheckBox("vserviceActivator xs20 yp+30","启动服务").OnEvent("Click", handleConnect),
        App.AddText("x+10", "本机: " . A_ComputerName),

        ; service state
        App.AddText("xs20 h30 yp+30 0x200", "当前服务状态: "),
        App.ARText("vonlineText w150 h30 x+1 0x200", "{1}", isListening)
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