RH_WorkflowOta(App) {
    wfConfig := config.read("workflow-ota")

    onMount() {
        for ctrl in App {
            if (ctrl.Name.includes("wf")) {
                ctrl.Value := wfConfig[ctrl.Name.replace("wf-", "")]
            }
        }
    }

    saveWorkflow(*) {
        form := JSON.parse(JSON.stringify(App.Submit(false)))
        config.write("workflow-ota", {
            profile: form["wf-profile"],
            routing: form["wf-routing"],
            resType: form["wf-resType"],
            market: form["wf-market"],
            source: form["wf-source"],
            ; ratecode: form["wf-ratecode"],
        })
    }

    return (
        App.AddText("x35 y35", "流程配置").SetFont("bold 10.5"),
        App.AddText("x35 y+15", "启用或关闭部分预订录入流程"),

        ; controller check-boxes
        App.AddCheckbox("vwf-profile x35 y+20", "录入 Profile").OnEvent("Click", saveWorkflow),
        App.AddCheckbox("vwf-routing x35 y+10", "录入 Routing").OnEvent("Click", saveWorkflow),
        App.AddCheckbox("vwf-resType x35 y+10", "录入 Res. Type").OnEvent("Click", saveWorkflow),
        App.AddCheckbox("vwf-market x35 y+10", "录入 Market Code").OnEvent("Click", saveWorkflow),
        App.AddCheckbox("vwf-source x35 y+10", "录入 Source Code").OnEvent("Click", saveWorkflow),
        ; App.AddCheckbox("vwf-ratecode x35 y+10", "录入 Rate Code").OnEvent("Click", saveWorkflow),

        onMount()
    )
}