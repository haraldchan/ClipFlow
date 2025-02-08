#Include "../../Servers/ProfileModifyNext_Server.ahk"

ServerAgentPanel(App) {
    agent := ProfileModifyNext_Agent({
        pool: A_ScriptDir . "\src\Servers\pmn-pool",
        interval: 3000,
        expiration: 1
    })

    connection := signal("未连接")
    
    ping(*) {
        status := App.getCtrlByName("status")
        res := agent.PING()
        if (!res) {
            connection.set("无响应...")
            status.SetFont("cRed Bold")
        } 

        connection.set(Format("在线 (响应主机: {1})", res[2]))
        status.SetFont("cGreen Bold")
    }

    return (
        App.AddGroupBox("Section w500 r20 ", "ProfileModifyNext 服务代理脚本"),

        App.AddCheckBox("xs20 yp+30","启动服务"),
        
        ; test connection
        App.AddButton("xs20 yp+20", "测试连接").OnEvent("Click", ping),
        App.ARText("vstatus x+10", "当前服务状态: {1}", connection)
    )
}