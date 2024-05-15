#Include "./PM_CopyPaste.ahk"

PM_App(App, popupTitle) {
    profileStored := JSON.parse(config.read("profileModify"))
    currentGuest := signal(profileStored)

    desc := "
    (
        1、请先打开“旅客信息”界面，点击
          “复制 (Alt+C)”；

        2、复制完成后请打开Opera Profile 界面，
          点击“填入 (Alt+V)”。
    )"

    fieldIndex := Map(
        "address", "地址",
        "birthday", "生日",
        "country", "国籍",
        "gender", "性别",
        "idNum", "证件号码",
        "idType", "证件类型",
        "language", "语言",
        "nameAlt", "全名",
        "nameFirst", "名字",
        "nameLast", "姓氏",
        "province", "省份"
    )

    listInitialize(curGuest, fieldIndex) {
        LV := App.getCtrlByType("ListView")

        for key, field in fieldIndex {
            val := curGuest.has(key) ? curGuest[key] : ""
            LV.Add(, field, val)
        }
    }

    updateList(curGuest, fieldIndex) {
        LV := App.getCtrlByType("ListView")
        
        for k, v in curGuest {
            LV.Modify(A_Index, , fieldIndex[k], v)
        }
    }

    showCopiedInfo(guest) {
        guestName := guest["nameAlt"] = " " 
            ? guest["nameFirst"] . " " . guest["nameLast"] 
            : guest["nameAlt"]

        result := MsgBox(Format("已读取。 当前客人：{1}`n`n 转到Opera? ", guestName), popupTitle, "4096 OKCancel T10")
        if (result = "OK") {
            try {
                WinActivate "ahk_class SunAwtFrame"
            }
        }
    }

    effect(currentGuest, (new) =>
        config.write("profileModify", JSON.stringify(new))
        updateList(new, fieldIndex)
        showCopiedInfo(new)
    )


    copyListField(LV, row) {
        if (config.read("profileModify") = "") {
            return
        }
        A_Clipboard := LV.GetText(row, 2)
        key := LV.GetText(row, 1)
        MsgBox(Format("已复制信息: `n`n{1} : {2}", key, A_Clipboard), popupTitle, "4096 T1")
    }

    psbCopy(*) {
        App.Hide()
        Sleep 200
        useSingleScript()
        currentGuest.set(PM_CopyPaste.copy())
        useSingleScript()

        App.getCtrlByName("paste").Focus()
    }

    pmsFill(*) {
        App.Hide()
        useSingleScript()
        Sleep 500
        PM_CopyPaste.paste(currentGuest.value)
        useSingleScript()

        App.getCtrlByName("copy").Focus()
    }

    return (
        App.AddGroupBox("R18 w250 y+20", popupTitle),
        App.AddText("xp10 yp+20", desc),
        App.AddText("y+12 h20 w230", "当前客人信息").SetFont("bold s11 q4", ""),
        App.AddListView("vguestInfo y+5 w230 h270", ["信息字段", "证件信息"]).OnEvent("DoubleClick", copyListField),
        App.AddButton("Default vcopy xp h35 w110 y+5", "复制 (&C)").OnEvent("Click", psbCopy),
        App.AddButton("vpaste xp+10 h35 w110 x+10 ", "填入 (&V)").OnEvent("Click", pmsFill),
        ; initializing ListView
        listInitialize(currentGuest.value, fieldIndex)
    )
}