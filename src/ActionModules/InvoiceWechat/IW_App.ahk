IW_App(App, popupTitle) {
    invoice := signal(JSON.parse(config.read("invoiceWechat")))

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
        config.write("invoiceWechat", JSON.stringify(invoice.value))
    }

    handleInfoListUpdate() {
        if (invoice.value = "") {
            return 
        }

        LV := App.getCtrlByName("infoList")
        LV.Modify(1, , fieldIndex["company"], invoice.value["company"])
        LV.Modify(2, , fieldIndex["taxNum"], invoice.value["taxNum"])
        if (invoice.value.Capacity > 2) {
            LV.Modify(3, , fieldIndex["address"], invoice.value["address"])
            LV.Modify(4, , fieldIndex["tel"], invoice.value["tel"])
            LV.Modify(5, , fieldIndex["bank"], invoice.value["bank"])
            LV.Modify(6, , fieldIndex["account"], invoice.value["account"])
        }
    }
    effect(invoice, () => handleInfoListUpdate())

    fillInfo() {
        xMarkImg := A_ScriptDir . "\src\Assets\invoiceXmark.PNG"
        try {
            WinActivate "ahk_exe VATIssue Terminal.exe"
        } catch {
            MsgBox("请先打开 一键开票", popupTitle, "T3")
            return
        }
        Sleep 500

        CoordMode "Pixel", "Screen"
        ImageSearch(&foundX, &foundY, 0, 0, A_ScreenWidth, A_ScreenHeight, xMarkImg)
        anchorX := foundX - 30
        anchorY := foundY + 10  

        infoStr := (invoice.value.Capacity > 2)
            ? invoice.value["company"] . "`t" . invoice.value["taxNum"] . "`t" . invoice.value["address"] . invoice.value["tel"] . "`t" . invoice.value["bank"] . invoice.value["account"]
            : invoice.value["company"] . "`t" . invoice.value["taxNum"]

        MouseMove anchorX, anchorY
        Sleep 200
        Send infoStr

        A_Clipboard := ""
    }

    copyListField(LV, row) {
        A_Clipboard := LV.GetText(row, 2)
        key := LV.GetText(row, 1)
        MsgBox(Format("已复制信息: `n`n{1} : {2}", key, A_Clipboard), popupTitle, "4096 T1")
    }

    listInit() {
        LV := App.getCtrlByName("infoList")
        LV.ModifyCol(1, 60)
        LV.ModifyCol(2, 350)

        LV.Add(, fieldIndex["company"])
        LV.Add(, fieldIndex["taxNum"])
        LV.Add(, fieldIndex["address"])
        LV.Add(, fieldIndex["tel"])
        LV.Add(, fieldIndex["bank"])
        LV.Add(, fieldIndex["account"])

        handleInfoListUpdate()
    }

    return (
        App.AddGroupBox("R10 w450 y+20", popupTitle),
        App.AddText("xp+10 yp+20 w200", "发票信息").SetFont("bold s11 q4", ""),
        App.AddListView("vinfoList Grid y+5 r6 w430", ["项目", "内容"])
           .OnEvent("DoubleClick", copyListField),
        App.AddButton("Default h35 w230 y+15", "开始填入")
           .OnEvent("Click", (*) => fillInfo()),
        listInit()
    )
}