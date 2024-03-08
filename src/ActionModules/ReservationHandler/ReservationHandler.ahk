#Include "./RH_Fedex.ahk"
#Include "./RH_OTA.ahk"

store := A_MyDocuments . "\ClipFlow.ini"
class ResvHandler {
    static name := "Reservation Handler"
    static title := "Flow Mode - " . this.name
    static popupTitle := "ClipFlow - " . this.name
    static desc := "
        (
            使用说明：

            1、先在Firefox中的“打印”状态订单
              使用扩展获取订单信息。

            2、获取订单后点击弹窗的“确定”返回
              Opera PMS，让脚本完成订单录入。
        )"
    static initXpos := 0
    static initYpos := 0

    static USE(App) {
        OnClipboardChange((*) => this.handleCapturedInfo(App))
        ui := [
            App.AddGroupBox("r7 w250 y+20", this.title),
            App.AddText("xp+10 yp+20", this.desc),
            App.AddButton("vstartBtn Default x40 h35 w230 y+15", "开始录入预订"),
        ]

        startBtn := interface.getCtrlByName("startBtn", ui)
        startBtn.OnEvent("Click", (*) => ResvHandler.modifyReservation(App))

    }

    static handleCapturedInfo(App) {
        if (!InStr(A_Clipboard, '"identifier":"ReservationHandler"')) {
            return
        }
        ; IniWrite(A_Clipboard, store, "ResvHandler", "JSON")   
        configRead(CONFIG_FILE)["resvHandler"]["JSON"] := A_Clipboard
        ; clb := A_Clipboard
        ; resvInfoObj := Jxon_Load(&clb)
        resvInfoObj := JSON.parse(A_Clipboard)

        this.showCurrentResvDetails(resvInfoObj, App)
    }

    static showCurrentResvDetails(resvInfoObj, App) {
        keyDesc := Map(
            "identifier", "插件标识",
            "agent", "订单来源",
            "orderId", "订单号",
            "guestNames", "住客姓名",
            "roomType", "预订房型",
            "roomQty", "订房数量",
            "remarks", "备注信息",
            "ciDate", "入住日期",
            "coDate", "退房日期",
            "roomRates", "房价构成",
            "bbf", "早餐构成",
            "payment", "支付方式",
            "invoiceMemo", "发票信息",
            "contacts", "联系方式",
            "creditCardNumbers", "虚拟卡号",
            "creditCardExp", "虚拟卡EXP",
            "resvType", "订单类型",
            "flightIn", "预抵航班",
            "flightOut", "离开航班",
            "ETA", "入住时间",
            "ETD", "退房时间",
            "stayHours", "在住时长",
            "daysActual", "计费天数",
            "crewNames", "机组姓名",
            "tripNum", "Trip No.",
            "tracking", "Tracking 单号",
        )

        ResvInfo := Gui("", "Reservation Handler")
        LV := ResvInfo.AddListView("h300", ["字段", "信息详情"])

        ResvDetails := []
        for k, v in resvInfoObj {
            if (v is String || v is Number) {
                outputVal := v
            } else if (v is Array) {
                outputVal := ""
                loop v.Length {
                    outputVal .= v[A_Index] . "，"
                }
                outputVal := SubStr(outputVal, 1, StrLen(outputVal) - 1)
            } else {
                outputVal := "`n"
                msgbox(v)
                for key, val in v {
                    outputVal .= Format("   {1}: {2}`n", key, val)
                }
            }

            ResvDetails.Push(
                LV.Add(, keyDesc[k], outputVal)
            )
        }

        LV.ModifyCol(1, 100)

        footer := [
            ResvInfo.AddButton("vstartBtn Default y+10", "转到 Opera"),
        ]

        ResvInfo.Show()

        checkAllBtn := interface.getCtrlByName("checkAllBtn", footer)
        startBtn := interface.getCtrlByName("startBtn", footer)
        startBtn.OnEvent("Click", toOpera)

        toOpera(*) {
            try {
                WinActivate "ahk_class SunAwtFrame"
                App.Show()
            } catch {
                MsgBox("请先打开 Opera 窗口。", ResvHandler.popupTitle)
            }
        }

    }

    static updateSelectedDetails() {
        
    }

    static modifyReservation(App) {
        App.Hide()
        ; bookingInfo := IniRead(store, "ResvHandler", "JSON")
        ; bookingInfoObj := Jxon_Load(&bookingInfo)
        bookingInfoObj := configRead(CONFIG_FILE)["resvHandler"][JSON]

        switch bookingInfoObj["agent"] {
            case "fedex":
                RH_Fedex(bookingInfoObj)
            case "kingsley":
                RH_Kingsley(bookingInfoObj)
            case "fliggy":
                RH_Fliggy(bookingInfoObj)
            case "webbeds":
                RH_Webbeds(bookingInfoObj)
            default:
        }
        Sleep 500
    }
}