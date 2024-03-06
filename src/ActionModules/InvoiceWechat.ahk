#Include "../../../Lib/Classes/utils.ahk"

class InvoiceWechat {
    static name := "Invoice Fill-in(Wechat)"
    static title := "Flow Mode - " . this.name
    static popupTitle := "ClipFlow - " . this.name
    static desc := "
    (
        1、请先打开小程序“微信发票助手”界面，
          点击 “复制全部资料”。

        2、复制完成后请打开一键开票界面，点
         击“开始填入”。
    )"

    static USE(App) {
        OnClipboardChange this.clipWithMsg
        ui := [
            App.AddGroupBox("R6 w250 y+20", this.title),
            App.AddText("xp+10 yp+20", this.desc),
            App.AddButton("Default h35 w230 y+15", "开始填入"),
        ]

        fillInBtn := ui[3]

        fillInBtn.OnEvent("Click", fillInfo)
        fillInfo(*){
            this.fillInfo(this.parseInvoiceInfo())
        }
    }

    static parseInvoiceInfo() {
        if (InStr(A_Clipboard, "名称：") && InStr(A_Clipboard, "税号：")) {
            invoiceInfo := StrSplit(A_Clipboard, "`n")
            invoiceInfoMap := Map()
            if (invoiceInfo.Length = 7) { ; probably is 6, check it
                invoiceInfoMap["company"] := SubStr(invoiceInfo[1], 4)
                invoiceInfoMap["taxNum"] := StrReplace(SubStr(invoiceInfo[2], 4), " ", "")
                invoiceInfoMap["address"] := SubStr(invoiceInfo[3], 6)
                invoiceInfoMap["tel"] := SubStr(invoiceInfo[4], 4)
                invoiceInfoMap["bank"] := SubStr(invoiceInfo[5], 6)
                invoiceInfoMap["account"] := SubStr(invoiceInfo[6], 6)
            } else {
                invoiceInfoMap["company"] := SubStr(invoiceInfo[1], 4)
                invoiceInfoMap["taxNum"] := StrReplace(SubStr(invoiceInfo[2], 4), " ", "")
            }
            return invoiceInfoMap
        } else {
            return
        }
    }

    static clipWithMsg() {
        msgMap := InvoiceWechat.parseInvoiceInfo()
        if (!(msgMap is Map)) {
            return
        }
        for k, v in msgMap {
            popupInfo .= Format("{1} : {2}`n", k, v)
        }
        toIssue := MsgBox(Format("
            (
            即将填入的信息：

            {1}

            确定(Enter):   打开 一键开票
            取消(Esc):     取消
            )", popupInfo), InvoiceWechat.popupTitle, "OKCancel")
        if (toIssue = "OK") {
            try {
                WinActivate "ahk_exe VATIssue Terminal.exe"
            } catch {
                MsgBox("请先打开 一键开票", InvoiceWechat.popupTitle)
            }
        }
    }

    static fillInfo(infoMap) {
        if (!(infoMap is Map)) {
            return
        }
        CoordMode "Mouse", "Screen"
        CoordMode "Pixel", "Screen"
        ; determine current issue type
        checkColor := [PixelGetColor(826, 837), PixelGetColor(1067, 453)]
        if (checkColor[1] = "0xFFFFCC" && checkColor[2] = "0xCCFFFF") {
            invoiceType := "split"
        } else if (checkColor[1] = "0xCCFFFF" && checkColor[2] = "0xCCFFFF") {
            invoiceType := "blue"
        } else {
            invoiceType := "yellow"
        }

        handleFill(coords){
            MouseMove coords[1][1], coords[1][2]
            click
            Send Format("{Text}{1}", infoMap["company"])
            sleep 50
            MouseMove coords[2][1], coords[2][2]
            click
            Send Format("{Text}{1}", infoMap["taxNum"])
            sleep 50
            try {
                MouseMove coords[3][1], coords[3][2]
                click
                Send Format("{Text}{1} {2}", infoMap["address"], infoMap["tel"])
                sleep 50
                MouseMove coords[4][1], coords[4][2]
                click
                Send Format("{Text}{1} {2}", infoMap["bank"], infoMap["account"])
                sleep 50
            }
        }

        if (invoiceType = "blue") {
            handleFill([[729, 233],[716, 262],[728, 290],[725, 319]])
        } else if (invoiceType = "yellow") {
            handleFill([[733, 185],[740, 215],[755, 243],[749, 272]])
        } else if (invoiceType = "split"){
            handleFill([[738, 199],[738, 233],[739, 259],[732, 290]])
        }
        A_Clipboard := ""
    }
}