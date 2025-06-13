#Include "./ReservationDetails.ahk"
#Include "./EntryBtns.ahk"
#Include "./RH_FedexBookingEntry.ahk"
#Include "./RH_OTA.ahk"

RH_App(App, moduleTitle, identifier) {
    README := FileRead(A_ScriptDir . "\src\ActionModules\ReservationHandler\README.txt", "UTF-8")

    curResv := signal({})
    resvSource := signal("")
    OnClipboardChange (*) => handleCaptured(identifier)
    handleCaptured(identifier){
        if (!A_Clipboard.includes(identifier)) {
            return
        }

        incommingResv := JSON.parse(A_Clipboard)
        incommingResv["ciDate"] := incommingResv["ciDate"].replace("-", "")
        incommingResv["coDate"] := incommingResv["coDate"].replace("-", "")

        curResv.set(incommingResv)
        config.write("JSON", JSON.stringify(incommingResv))
    }

    onMount() {
        LV := App.getCtrlByType("ListView")
        LV.ModifyCol(1, 100)
        LV.ModifyCol(2, 200)
        try {
            curResv.set(JSON.parse(config.read("JSON")))       
        }
    }

    return (
        App.AddGroupBox("Section R18 w685 y+20", ""),
        App.AddText("xp15", moduleTitle),

        ; read me info
        App.AddText("xs20 y+10 w150 h35 ", "使用说明").SetFont("s10.5 Bold"),
        App.AddText("xs20 y+1 w270 h250", README).SetFont("s10"),

        ; reservation info
        App.ARText("x360 y140 w300 h30", "订单详情  {1}", resvSource).SetFont("s13 q5 Bold"),
        ReservationDetails(App, curResv),

        ; entry btns
        EntryBtns(App, curResv, resvSource)

        onMount()
    )
}