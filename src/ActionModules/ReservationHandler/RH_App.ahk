#Include "./ReservationDetails.ahk"
#Include "./EntryBtns.ahk"
#Include "./Settings/RH_Settings.ahk"

RH_App(App, moduleTitle, identifier) {
    README := FileRead(A_ScriptDir . "\src\ActionModules\ReservationHandler\README.txt", "UTF-8")

    r := {}
    curResv := signal(RH_Models.otaListFields.keys().map(key => r.DefineProp(key, { Value: "" })))
    resvSource := signal("")
    OnClipboardChange (*) => handleCaptured(identifier)
    handleCaptured(identifier) {
        if (!A_Clipboard.includes(identifier)) {
            return
        }

        incommingResv := JSON.parse(A_Clipboard)
        incommingResv["ciDate"] := incommingResv["ciDate"].replace("-", "")
        incommingResv["coDate"] := incommingResv["coDate"].replace("-", "")

        curResv.set(incommingResv)
        config.write("currentReservation", JSON.stringify(incommingResv))
    }

    effect(curResv, handleResvSourceUpdate)
    handleResvSourceUpdate(cur) {
        if (cur["agent"] == "fedex") {
            resvSource.set("FEDEX: " . cur["resvType"])
        } else {
            resvSource.set(Format(": {1}  {2}", cur["agent"].toTitle(), cur["orderId"]))
        }
    }

    onMount() {
        LV := App.getCtrlByType("ListView")
        LV.ModifyCol(1, 100)
        LV.ModifyCol(2, 200)

        storedResv := config.read("currentReservation")
        if (storedResv) {
            curResv.set(JSON.parse(storedResv))
        }
    }

    return (
        App.AddGroupBox("Section R18 w685 y+20", ""),
        App.AddText("xp15", moduleTitle),

        ; read me info
        App.AddGroupBox("Section yp+25 w320 h200"),
        App.AddText("xp10 h35 w80 0x1", "使用说明").SetFont("s10.5 Bold"),
        App.AddText("xp yp+30 w270 h150", README).SetFont("s10"),
        
        ; options
        ; append remarks to comment
        App.AddGroupBox("Section xp-10 y+25 w320 h209"),
        App.AddText("xp10 w80 h35 0x1", "设置选项").SetFont("s10.5 Bold"),
        App.AddButton("x+10 h23", "更多").OnEvent("Click", RH_Settings),

        ; add remarks to comment
        App.AddCheckbox("vwithRemarks xs10 yp+30 h25", "将备注添加到 Comment"),

        ; add remarks to trace
        App.AddCheckbox("vwithTrace xs10 yp+30 h25", "将备注添加到 Trace"),
        
        ; add extra packages
        App.AddText("xs10 y+5 h25 0x200", "需添加的额外 Package (不包括早餐；以空格分隔)"),
        App.AddText("xs10 y+1 h25 0x200", "Pkg Code.").SetFont("Bold"),
        App.AddEdit("vextraPackages x+5 w200 h25"),

        ; override ratecode
        App.AddText("xs10 y+5 h25 0x200", "覆盖 RateCode (不使用默认)"),
        App.AddText("xs10 y+1 h25 0x200", "RateCode.").SetFont("Bold"),
        App.AddEdit("voverridenRateCode x+5 w200 h25", ""),
        
        ; reservation details
        App.ARText("x380 y140 w300 h25", "订单详情  {1}", resvSource).SetFont("s13 q5 Bold"),
        ReservationDetails(App, curResv),
        
        ; entry btns
        EntryBtns(App, curResv),
        onMount()
    )
}