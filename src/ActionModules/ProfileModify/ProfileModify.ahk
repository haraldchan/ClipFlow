#Include "../../../Lib/ClipFlow/dict.ahk"
#Include "../../../Lib/ClipFlow/DictIndex.ahk"

class ProfileModify {
    static name := "Profile Modify"
    static title := "Flow Mode - " . this.name
    static popupTitle := "ClipFlow - " . this.name
    static desc := "
    (
        1、请先打开“旅客信息”界面，点击
          “开始复制”；

        2、复制完成后请打开Opera Profile 界面，
          点击“开始填入”。
    )"
    static profileAnchor := (A_OSVersion = "6.1.7601")
            ? "\\10.0.2.13\fd\19-个人文件夹\HC\Software - 软件及脚本\AHK_Scripts\ClipFlow\src\assets\ProfileAnchorWin7.PNG"
            : "\\10.0.2.13\fd\19-个人文件夹\HC\Software - 软件及脚本\AHK_Scripts\ClipFlow\src\assets\ProfileAnchor.PNG"
    static altAnchor := (A_OSVersion = "6.1.7601")
            ? "\\10.0.2.13\fd\19-个人文件夹\HC\Software - 软件及脚本\AHK_Scripts\ClipFlow\src\assets\AltAnchorWin7.PNG"
            : "\\10.0.2.13\fd\19-个人文件夹\HC\Software - 软件及脚本\AHK_Scripts\ClipFlow\src\assets\AltAnchor.PNG"

    static USE(App) {
        ; GUI
        ui := [
            App.AddGroupBox("R6 w250 y+20", this.title),
            App.AddText("xp+10 yp+20", this.desc),
            App.AddButton("vcopyBtn Default xp h35 w110 y+15", "开始复制"),
            App.AddButton("vpasteBtn Disabled xp+10 h35 w110 x+10 ", "开始填入"),
        ]
        
        copyBtn := interface.getCtrlByName("copyBtn", ui)
        pasteBtn := interface.getCtrlByName("pasteBtn", ui)
        ; function
        copyBtn.OnEvent("Click", psbCopy)
        psbCopy(*) {
            App.Hide()
            Sleep 200
            global profileCache := this.copy()
            copyBtn.Enabled := false
            pasteBtn.Enabled := true
            ; App.Show()
            pasteBtn.Focus()
        }
        
        pasteBtn.OnEvent("Click", psbPaste)
        psbPaste(*) {
            App.Hide()
            this.paste(profileCache)
            Sleep 200
            copyBtn.Enabled := true
            pasteBtn.Enabled := false
            copyBtn.Focus()
        }
    }

    static copy() {
        CoordMode "Pixel", "Window"
        try {
            WinActivate "旅客信息"
        } catch {
            MsgBox("请先打开 旅客信息 窗口", this.popupTitle)
            utils.cleanReload(winGroup)
        }
        checkGuestType := [PixelGetColor(464, 87), PixelGetColor(553, 87), PixelGetColor(649, 87)]
        loop checkGuestType.Length {
            if (checkGuestType[A_Index] = "0x000000") {
                gType := A_Index
                break
            }
        }
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
                guestProfile["idType"] := ""
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
            guestProfile["language"] := "E"
            guestProfile["idType"] := "NOP"
            guestProfile["nameLast"] := infoArr[4]
            guestProfile["nameFirst"] := infoArr[5]
            guestProfile["country"] :=  getCountryCode(infoArr[6])
        }

        for k, v in guestProfile {
            popupInfo .= Format("{1}：{2}`n", k, v)
        }
        toOpera := MsgBox(Format("
            (   
            即将填入的信息：

            {1}

            确定(Enter)：     打开 Opera
            取消(Esc)：       留在 旅客信息
            )", popupInfo), this.popupTitle, "OKCancel 4096")
        if (toOpera = "OK") {
            try {
                WinActivate "ahk_class SunAwtFrame"
            } catch {
                MsgBox("请先打开 Opera 窗口。", this.popupTitle)
            }
        }
        return guestProfile
    }

    static paste(guestProfileMap) {
        CoordMode "Pixel", "Screen"
        if (ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenWidth, this.profileAnchor))  {
            anchorX := FoundX
            anchorY := FoundY
        } else {
            ; msgbox("请先打开Profile界面", this.popupTitle)
            WinMaximize "ahk_class SunAwtFrame"
            anchorX := 205
            anchorY := 203           
        }
        WinSetAlwaysOnTop true, "ahk_class SunAwtFrame"
        CoordMode "Mouse", "Screen"
        BlockInput true
        ; { fillin common info: nameLast, nameFirst, language, gender, country, birthday, idType, idNum
        MouseMove anchorX+228, anchorY+80
        Click 3
        Sleep 50
        Send Format("{Text}{1}", guestProfileMap["nameLast"])
        Sleep 50
        MouseMove anchorX+188, anchorY+104
        Click 3
        Sleep 50
        Send Format("{Text}{1}", guestProfileMap["nameFirst"])
        Sleep 50
        MouseMove anchorX+155, anchorY+134
        Click 3
        Sleep 50
        Send Format("{Text}{1}", guestProfileMap["language"])
        Sleep 50
        MouseMove anchorX+230, anchorY+133
        Click 3
        Sleep 50
        Send Format("{Text}{1}", guestProfileMap["gender"])
        Sleep 50
        MouseMove anchorX+150, anchorY+284
        Click 3
        Sleep 50
        Send Format("{Text}{1}", guestProfileMap["country"])
        Sleep 50
        MouseMove anchorX+635, anchorY+78
        Click 3
        Sleep 50
        Send Format("{Text}{1}", guestProfileMap["birthday"])
        Sleep 50
        MouseMove anchorX+633, anchorY+99
        Click 3
        Sleep 50
        Send Format("{Text}{1}", guestProfileMap["idType"])
        Sleep 50
        MouseMove anchorX+658, anchorY+121
        Click 3
        Sleep 50
        Send Format("{Text}{1}", guestProfileMap["idNum"])
        Sleep 50
        ; }
        if (guestProfileMap.Has("nameAlt")) {
            ; { with hanzi name
            ; fillin: address, province, nameAlt, gender(in nameAlt window)
            MouseMove anchorX+227, anchorY+161
            Click 3
            Sleep 50
            Send Format("{Text}{1}", guestProfileMap["address"])
            Sleep 50
            MouseMove anchorX+233, anchorY+282
            Click 3
            Sleep 50
            Send Format("{Text}{1}", guestProfileMap["province"])
            Sleep 50

            MouseMove anchorX+247, anchorY+76 ; open alt name win
            Click 1
            Sleep 3500

            if (ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenWidth, this.AltAnchor)) {
                altX := FoundX
                altY := FoundY 
            } else {
                altX := 419
                altY := 369                 
            }
            MouseMove altX+224, altY+11
            Click 3
            Sleep 50
            Send Format("{Text}{1}", guestProfileMap["nameAlt"])
            Sleep 50
            MouseMove altX+319, altY+101
            Click 3
            Sleep 50
            Send Format("{Text}{1}", guestProfileMap["gender"])
            Sleep 50
            Send "{Enter}"
            Sleep 100
            Send "!o"
            Sleep 200
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
    }
}