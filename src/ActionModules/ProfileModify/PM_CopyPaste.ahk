; #Include "./Dict.ahk"
; #Include "./DictIndex.ahk"

class PM_CopyPaste {
    static copy() {
        guestType := this.getGuestType()
        captured := this.captureGuestInfo(guestType)
        guestInfoMap := this.parseGuestInfo(guestType, captured)
        
        return guestInfoMap
    }

    static getGuestType() {
        CoordMode "Pixel", "Window"
        try {
            WinActivate "旅客信息"
        } catch {
            MsgBox("请先打开 旅客信息 窗口", "Profile Modify", "T1")
            utils.cleanReload(winGroup)
        }
        checkGuestType := [PixelGetColor(464, 87), PixelGetColor(553, 87), PixelGetColor(649, 87)]
        loop checkGuestType.Length {
            if (checkGuestType[A_Index] = "0x000000") {
                guestType := A_Index
                break
            }
        }

        return guestType
    }

    static captureGuestInfo(gType) {
        CoordMode "Mouse", "Window"
        BlockInput true
        if (WinExist("旅客信息")) {
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

        return capturedInfo
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
            guestProfile["nameLast"] := useDict.getFullnamePinyin(infoArr[4])[1]
            guestProfile["nameFirst"] := useDict.getFullnamePinyin(infoArr[4])[2]
            if (StrLen(infoArr[3]) = 18) {
                guestProfile["idType"] := "IDC"
            } else if (StrLen(infoArr[3]) = 9) {
                guestProfile["idType"] := (SubStr(guestProfile["idNum"], 1, 1) = "C") ? "MRP" : "IDP"
            } else {
                guestProfile["idType"] := " "
            }
            guestProfile["address"] := infoArr[5]
            guestProfile["province"] := useDict.getProvince(infoArr[6])
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
        } else if (gType = 3) {
            ; from abroad
            guestProfile["nameAlt"] := " "
            guestProfile["language"] := "E"
            guestProfile["idType"] := "NOP"
            guestProfile["address"] := ""
            guestProfile["nameLast"] := infoArr[4]
            guestProfile["nameFirst"] := infoArr[5]
            guestProfile["country"] := useDict.getCountryCode(infoArr[6])
            guestProfile["province"] := " "
        }

        return guestProfile
    }

    static waitAltWin(anchorX, anchorY){
        CoordMode "Pixel", "Screen"
        WIN_HEADER_BLUE := "0xBFCDDB"
        loop 16 {
            Sleep 250
            if (PixelGetColor(anchorX, anchorY - 98) != WIN_HEADER_BLUE) {
                continue
            } else {
                Sleep 500 
                break
            }
        }
    }

    static waitProfileClose(anchorX, anchorY, AnchorImage) {
        CoordMode "Pixel", "Screen"
        loop 16 {
            Sleep 250
            if(!ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, AnchorImage)) {
                break
            }
        }
    }

    static paste(guestProfileMap) {
        CoordMode "Pixel", "Screen"
        AnchorImage := A_ScriptDir . "\src\Assets\AltNameAnchor.PNG"
        anchorX := 0
        anchorY := 0

        if (ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, AnchorImage)) {
            anchorX := FoundX - 10
            anchorY := FoundY
        } else {
            msgbox("not found", , "T1")
            return
        }

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

            this.waitAltWin(anchorX, anchorY)

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
            )", "Profile Modify", "OKCancel T2 4096")
        if (backToPsb = "OK") {
            WinActivate "ahk_class SunAwtFrame"
            Send "!o"

            this.waitProfileClose(anchorX, anchorY, AnchorImage)

            if (WinExist("旅客信息")) {
                WinActivate "旅客信息"
            } else {
                WinActivate "ahk_exe hotel.exe"
            }
        }
    }
}