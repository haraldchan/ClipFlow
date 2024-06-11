IW_App(App, popupTitle) {
    invoice := signal(Map())

    fieldIndex := Map(
        "company", "公司名称",
        "taxNum", "税号",
        "address", "注册地址",
        "tel", "电话",
        "bank", "开户银行",
        "account", "账号",
    )

    OnClipboardChange (*) => handleCaptured()
    handleCaptured() {
        if (!InStr(A_Clipboard, "名称：") && !InStr(A_Clipboard, "税号：")) {
            return
        }

        parseInvoiceInfo(A_Clipboard)
        handleInfoListUpdate()

        App.Show()
    }

    parseInvoiceInfo(clb) {
        invoiceInfo := StrSplit(clb, "`n")
        invoiceInfoMap := Map()
        invoiceInfoMap["company"] := SubStr(invoiceInfo[1], 4)
        invoiceInfoMap["taxNum"] := StrReplace(SubStr(invoiceInfo[2], 4), " ", "")

        if (invoiceInfo.Length = 7) {
            invoiceInfoMap["address"] := SubStr(invoiceInfo[3], 6)
            invoiceInfoMap["tel"] := SubStr(invoiceInfo[4], 4)
            invoiceInfoMap["bank"] := SubStr(invoiceInfo[5], 6)
            invoiceInfoMap["account"] := SubStr(invoiceInfo[6], 6)
        }

        invoice.set(invoiceInfoMap)
    }

    handleInfoListUpdate() {
        LV := App.getCtrlByName("infoList")
        LV.Modify(1, , fieldIndex["company"], invoice.value["company"])
        LV.Modify(2, , fieldIndex["taxNum"], invoice.value["taxNum"])
        if (invoice.value.Capacity > 2) {
            LV.Modify(3, , fieldIndex["company"], invoice.value["company"])
            LV.Modify(4, , fieldIndex["company"], invoice.value["company"])
            LV.Modify(5, , fieldIndex["company"], invoice.value["company"])
            LV.Modify(6, , fieldIndex["company"], invoice.value["company"])
        }
    }

    fillInfo() {
        xMarkImg := "../Assets/invoiceXmark.PNG"
        ImageSearch(&foundX, &foundY, 0, 0, A_ScreenWidth, A_ScreenHeight, xMarkImg)
        anchorX := foundX - 30
        anchorY := foundY

        infoStr := (invoice.value.Capacity > 2)
            ? invoice.value["company"] . "`t" . invoice.value["taxNum"] . "`t" . invoice.value["address"] . invoice.value["tel"] . "`t" . invoice.value["bank"] . invoice.value["account"]
            : invoice.value["company"] . "`t" . invoice.value["taxNum"]

        try {
            WinActivate "ahk_exe VATIssue Terminal.exe"
        } catch {
            MsgBox("请先打开 一键开票", popupTitle, "T3")
            return
        }

        MouseMove anchorX, anchorY
        Sleep 200
        Send infoStr

        A_Clipboard := ""
    }

    return (
        App.AddGroupBox("R15 w250 y+20", popupTitle),
        App.AddText("xp+10 yp+20", "发票信息").SetFont("bold s11 q4", ""),
        App.AddListView("vinfoList y+5 r7 230", ["项目", "内容"]),
        App.AddButton("Default h35 w230 y+15", "开始填入")
    )
}