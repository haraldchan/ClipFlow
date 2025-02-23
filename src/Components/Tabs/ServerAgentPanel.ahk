#Include "../../Servers/ProfileModifyNext_Server.ahk"
#Include "../../Servers/QM2_Server.ahk"
#Include "./ServerAgentPanels/ServerAgentPanel_Agent.ahk"
#Include "./ServerAgentPanels/ServerAgentPanel_Client.ahk"
#Include "./ServerAgentPanels/QM2_Panel.ahk"

ServerAgentPanel(App) {
    isListening := signal("离线")
    global pmnAgent := ProfileModifyNext_Agent({
        pool: A_ScriptDir . "\src\Servers\pmn-pool",
        interval: 3000,
        expiration: 1,
        collectRange : 10,
        safePost: false,
        isListening: isListening
    })
    
    return (
        App.AddText("x30 y75 h40 w580", "ProfileModifyNext Server").SetFont("s13 q5 Bold"),

        ; server-side options
        ServerAgentPanel_Agent(App, config.read("agentEnabled"), pmnAgent, isListening),
        
        ; client-side options
        ServerAgentPanel_Client(App, config.read("clientEnabled"), pmnAgent)

        ; qm2 panel
        QM_Panel(App, isListening)
    )
}