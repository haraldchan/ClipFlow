#Include "./Dict.ahk"
#Include "./DictIndex.ahk"

class ProfileModify {
    static name := "Profile Modify"
    static title := "Flow Mode - " . this.name
    static popupTitle := "ClipFlow - " . this.name
    static desc := "
    (
        1、请先打开“旅客信息”界面，点击
          “复制 (Alt+C)”；

        2、复制完成后请打开Opera Profile 界面，
          点击“填入 (Alt+V)”。
    )"

    static AltNameAnchorPath := A_ScriptDir . "\src\Assets\AltNameAnchor.PNG"

    static USE(App) {
        profileStored := JSON.parse(config.read("profileModify"))
        currentGuest := signal(profileStored)
        effect(currentGuest, (new) => 
            MsgBox(
                Format("已读取。 当前客人：{1}", new["nameAlt"] = " " ? (new["nameFirst"] . " " . new["nameLast"]) : new["nameAlt"])
                , "Profile Modify", "4096 T2")
            )

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

        ; GUI
        ui := [
            App.AddGroupBox("R18 w250 y+20", this.title),
            App.AddText("xp10 yp+20", this.desc),

            App.AddText("vtitle y+12 h20 w230", "当前客人信息"),

            App.AddListView("vguestInfo y+5 w230 h270", ["信息字段", "证件信息"]),

            App.AddButton("vcopyBtn Default xp h35 w110 y+5", "复制 (&C)"),
            App.AddButton("vpasteBtn xp+10 h35 w110 x+10 ", "填入 (&V)"),
        ]
        
        copyBtn := interface.getCtrlByName("copyBtn", ui)
        pasteBtn := interface.getCtrlByName("pasteBtn", ui)
        guestInfo := interface.getCtrlByName("guestInfo", ui)
        interface.getCtrlByName("title", ui).SetFont("bold s11 q4","")

        for key, field in fieldIndex {
            val := currentGuest.value.has(key) ? currentGuest.value[key] : ""
            guestInfo.Add(, field, val)
        }

        ; function
        guestInfo.OnEvent("DoubleClick", copyField)
        copyField(LV, row) {
            if (config.read("profileModify") = "") {
                return
            }
            A_Clipboard := LV.GetText(row, 2)
            key := LV.GetText(row, 1)
            copiedPopup := Format("已复制信息: `n`n{1} : {2}", key, A_Clipboard)
            MsgBox(copiedPopup, this.popupTitle, "4096 T1")
        }

        copyBtn.OnEvent("Click", psbCopy)
        psbCopy(*) {
            App.Hide()
            Sleep 200
            useSingleScript()
            currentGuest.set(this.copy())
            useSingleScript()
            config.write("profileModify", JSON.stringify(currentGuest.value))
            this.updateList(currentGuest.value, fieldIndex, guestInfo)

            WinActivate "ahk_class SunAwtFrame"
            App.Show()
            pasteBtn.Focus()
        }
        
        pasteBtn.OnEvent("Click", psbPaste)
        psbPaste(*) {
            App.Hide()
            useSingleScript()
            this.paste(currentGuest.value)
            useSingleScript()
            copyBtn.Focus()
        }
    }

    static updateList(curGuest, fieldIndex , LV) {
        for k, v in curGuest {
            LV.Modify(A_Index,, fieldIndex[k] , v)
        }
    }

    static suspendQM2(){
        QM2Path := "QM2.ahk"

        DetectHiddenWindows true
        SetTitleMatchMode 2

        if (WinExist("QM2 for FrontDesk 2.2.0")) {
            PostMessage 0x0111, 65305,,, QM2Path . " - AutoHotkey"  ; Suspend.
        }
    }

    static copy() {
        CoordMode "Pixel", "Window"
        try {
            WinActivate "旅客信息"
        } catch {
            MsgBox("请先打开 旅客信息 窗口", this.popupTitle, "T1")
            utils.cleanReload(winGroup)
        }
        checkGuestType := [PixelGetColor(464, 87), PixelGetColor(553, 87), PixelGetColor(649, 87)]
        loop checkGuestType.Length {
            if (checkGuestType[A_Index] = "0x000000") {
                gType := A_Index
                break
            }
        }

        ; this.suspendQM2()

        return this.capture(gType)
    }
    
    static capture(gType) {
        CoordMode "Mouse", "Window"
        BlockInput true
        if (WinExist("旅客信息")){
            WinSetAlwaysOnTop true, "旅客信息"
        }
        capturedInfo := []
        ; capture: birthday
        MouseMove 755, 147
        click 1
        Sleep 50
        Send "^c"
        Sleep 100
        capturedInfo.Push(A_Clipboard)
        ; capture: gender
        MouseMove 565, 147
        Sleep 50
        Click 
        Sleep 50
        Click "Right"
        Sleep 50
        Send "{c}"
        Sleep 50
        Send "{Esc}"
        Sleep 50
        capturedInfo.Push(A_Clipboard)
        Sleep 50
        if (gType = 1) {
            ; from Mainland
            ; capture: id
            MouseMove 738, 235
            Click "Down"
            Sleep 50
            MouseMove 483, 235
            Click "Up"
            Sleep 50
            Send "^c"
            Sleep 50
            capturedInfo.Push(A_Clipboard)
            ; capture: fullname
            MouseMove 658, 116
            Click "Down"
            Sleep 50
            MouseMove 498, 116
            Click "Up"
            Sleep 50
            Send "^c"
            Sleep 50
            capturedInfo.Push(A_Clipboard)
            ; capture: address
            MouseMove 519, 262
            Click "Down"
            Sleep 50
            MouseMove 789, 262
            Click "Up"
            Sleep 50
            Send "^c"
            Sleep 50           
            capturedInfo.Push(A_Clipboard)
            Sleep 50
            ; capture: province
            MouseMove 587, 292
            Sleep 50
            Click 
            Sleep 50
            Click "Right"
            Sleep 50
            Send "c"
            Sleep 50
            Send "{Esc}"
            Sleep 50
            capturedInfo.Push(A_Clipboard)
        } else if (gType = 2) {
            ; from HK/MO/TW
            ; capture: id
            MouseMove 652, 291
            Click "Down"
            Sleep 50
            MouseMove 506, 291
            Click "Up"
            Send "^c"
            Sleep 50
            capturedInfo.Push(A_Clipboard)
            ; capture: fullname
            MouseMove 658, 116
            Click "Down"
            Sleep 50
            MouseMove 498, 116
            Click "Up"
            Sleep 50
            Send "^c"
            Sleep 50
            capturedInfo.Push(A_Clipboard)
            ; capture: nameLast
            MouseMove 759, 203
            Click "Down"
            Sleep 50
            MouseMove 500, 203
            Click "Up"
            Sleep 50
            Send "^c"
            Sleep 50
            capturedInfo.Push(A_Clipboard)
            ; capture: nameFirst
            MouseMove 759, 233
            Click "Down"
            Sleep 50
            MouseMove 500, 233
            Click "Up"
            Sleep 50
            Send "^c"
            Sleep 50
            capturedInfo.Push(A_Clipboard)
            Sleep 50
        } else if (gType = 3) {
            ; from abroad
            ; capture: id
            MouseMove 666, 290
            Sleep 50
            Click 2
            Sleep 50
            Send "^c"
            Sleep 50
            capturedInfo.Push(A_Clipboard)
            ; capture: nameLast
            MouseMove 759, 203
            Click "Down"
            Sleep 50
            MouseMove 500, 203
            Click "Up"
            Sleep 50
            Send "^c"
            Sleep 50
            capturedInfo.Push(A_Clipboard)
            ; capture: nameFirst
            MouseMove 759, 233
            Click "Down"
            Sleep 50
            MouseMove 500, 233
            Click "Up"
            Sleep 50
            Send "^c"
            Sleep 50
            capturedInfo.Push(A_Clipboard)
            ; capture: country
            MouseMove 670, 322
            Sleep 50
            Click 
            Sleep 50
            Click "Right"
            Sleep 50
            Send "c"
            Sleep 50
            Send "{Esc}"
            Sleep 50
            capturedInfo.Push(A_Clipboard)
            Sleep 50
        }
        WinSetAlwaysOnTop false, "旅客信息"
        BlockInput false
        return this.parseGuestInfo(gType, capturedInfo)
    }

    static parseGuestInfo(gType, infoArr) {
        guestProfile := Map()
        guestProfile["birthday"] := FormatTime(infoArr[1], "MMddyyyy")
        guestProfile["gender"] := (infoArr[2] = "男") ? "Mr" : "Ms"
        guestProfile["idNum"] := infoArr[3]
        if (gType = 1) {
            ; from Mainland
            guestProfile["language"] := "C"
            guestProfile["country"] := "CN"
            guestProfile["nameAlt"] := infoArr[4]
            guestProfile["nameLast"] := getFullnamePinyin(infoArr[4])[1]
            guestProfile["nameFirst"] := getFullnamePinyin(infoArr[4])[2]
            if (StrLen(infoArr[3]) = 18) {
                guestProfile["idType"] := "IDC"
            } else if (StrLen(infoArr[3]) = 9) {
                guestProfile["idType"] := (SubStr(guestProfile["idNum"], 1, 1) = "C") ? "MRP" : "IDP"
            } else {
                guestProfile["idType"] := " "
            }
            guestProfile["address"] := infoArr[5]
            guestProfile["province"] := getProvince(infoArr[6])
        } else if (gType = 2) {
            guestProfile["language"] := "E"
            guestProfile["country"] := "CN"
            guestProfile["nameAlt"] := infoArr[4]
            guestProfile["nameLast"] := infoArr[5]
            guestProfile["nameFirst"] := infoArr[6]
            guestProfile["address"] := ""
            if (SubStr(guestProfile["idNum"], 1, 1) = "H") {
                guestProfile["idType"] := "HKC"
                guestProfile["province"] := "HK"
            } else if (SubStr(guestProfile["idNum"], 1, 1) = "M") {
                guestProfile["idType"] := "HKC"
                guestProfile["province"] := "MO"
            } else {
                guestProfile["idType"] := "TWT"
                guestProfile["province"] := "TW"
            }
        } else if (gType = 3)  {
            ; from abroad
            guestProfile["nameAlt"] := " "
            guestProfile["language"] := "E"
            guestProfile["idType"] := "NOP"
            guestProfile["address"] := ""
            guestProfile["nameLast"] := infoArr[4]
            guestProfile["nameFirst"] := infoArr[5]
            guestProfile["country"] :=  getCountryCode(infoArr[6])
            guestProfile["province"] := " "
        }

        ; this.suspendQM2()

        return guestProfile
    }

    static paste(guestProfileMap) {
        CoordMode "Pixel", "Screen"
        anchorX := 0
        anchorY := 0

        if (WinGetMinMax("ahk_class SunAwtFrame") = 1) {
            anchorX := 451 - 10
            anchorY := 278
        } else if (ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, this.AltNameAnchorPath))  {
            anchorX := FoundX - 10
            anchorY := FoundY
        } else {
            msgbox("not found",,"T1")
            return
        }

        ; this.suspendQM2()

        WinSetAlwaysOnTop true, "ahk_class SunAwtFrame"
        CoordMode "Mouse", "Screen"
        BlockInput true
        ; { fillin common info: nameLast, nameFirst, language, gender, country, birthday, idType, idNum
        MouseMove anchorX, anchorY
        Click 3
        Sleep 100
        Send Format("{Text}{1}", guestProfileMap["nameLast"])

        Send "{Tab}"
        Sleep 100
        Send Format("{Text}{1}", guestProfileMap["nameFirst"])

        loop 2 { 
            Send "{Tab}" 
        } 
        Sleep 100
        Send Format("{Text}{1}", guestProfileMap["language"])

        Send "{Tab}"
        Sleep 100
        Send Format("{Text}{1}", guestProfileMap["gender"])

        Send "{Tab}" 
        Sleep 100
        Send Format("{Text}{1}", guestProfileMap["address"])

        loop 6 { 
            Send "{Tab}" 
        } 
        Sleep 100
        Send Format("{Text}{1}", guestProfileMap["country"])

        Send "{Tab}"
        Sleep 100
        Send Format("{Text}{1}", guestProfileMap["province"])

        loop 9 { 
            Send "{Tab}" 
        } 
        Sleep 100
        Send Format("{Text}{1}", guestProfileMap["birthday"])

        Send "{Tab}"
        Sleep 100
        Send Format("{Text}{1}", guestProfileMap["idNum"])
        Sleep 100

        MouseMove anchorX + 393, anchorY + 28
        Sleep 100
        Click 3
        Send Format("{Text}{1}", guestProfileMap["idType"])
        Sleep 100
        Send "{Tab}"
        Sleep 100
        ; }
        if (guestProfileMap["nameAlt"] != " ") {
            ; { with hanzi name
            ; fillin: nameAlt, gender(in nameAlt window)
            MouseMove anchorX + 10, anchorY + 10 ; open alt name win
            Sleep 50
            Click 1
            Sleep 3500

            Send Format("{Text}{1}", guestProfileMap["nameAlt"])
            Sleep 100

            loop 3 { 
                Send "{Tab}" 
            } 
            Sleep 100
            Send Format("{Text}{1}", "C")

            Send "{Tab}" 
            Sleep 100
            Send Format("{Text}{1}", guestProfileMap["gender"])
            Sleep 100
            Send "{Tab}"
            Sleep 100
            Send "!o"
            Sleep 100
        }
        BlockInput false
        WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"

        backToPsb := MsgBox("
            (
                已完成Modify！

                确定(Enter)：    回到 旅客信息
                取消(Esc)：      留在 Opera
            )", this.popupTitle, "OKCancel T2 4096")
        if (backToPsb = "OK") {
            Send "!o"
            Sleep 1500
            if (WinExist("旅客信息")) {
                WinActivate "旅客信息"
            } else {
            WinActivate "ahk_exe hotel.exe"
            }
        } 

        ; this.suspendQM2()
    }
}