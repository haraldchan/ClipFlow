#Include "../../Servers/UnifiedAgent.ahk"
#Include "./ServerAgentPanels/ServerAgentPanel_Agent.ahk"
#Include "./ServerAgentPanels/ServerAgentPanel_Client.ahk"
#Include "./ServerAgentPanels/QM2_Panel.ahk"
#Include "../UnifiedAgentModal.ahk"

ServerAgentPanel(App) {
    isListening := signal("离线")

    global agent := UnifiedAgent({
        pool: A_ScriptDir . "\src\Servers\pmn-pool",
        qmPool: A_ScriptDir . "\src\Servers\qm-pool",
        interval: 3000,
        expiration: 480,
        collectRange: 15,
        safePost: false,
        isListening: isListening
    })


    return (
        App.AddText("x30 y75 h40 w580", "ProfileModifyNext Server").SetFont("s13 q5 Bold"),
        
        ; server-side options
        ServerAgentPanel_Agent(App, config.read("agentEnabled"), isListening),
        
        ; client-side options
        ServerAgentPanel_Client(App, config.read("clientEnabled"))
    )
}