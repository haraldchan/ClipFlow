class PMN_FillIn {
    static AnchorImage := A_ScriptDir . "\src\Assets\AltNameAnchor.PNG"
    static FOUND := "0x000080"
    static NOT_FOUND := "0x008080"

    static fill(currentGuest) {
        if (this.matchHistory(currentGuest) = this.FOUND) {
            Send "!o"
            utils.waitLoading()

            MsgBox("已匹配原有 Profile", "Profile Modify Next", "T1 4096")
        } else {
            Send "!c"
            utils.waitLoading()
            Send "!n"
            utils.waitLoading()
        
            this.fillAction(this.parse(currentGuest))
            utils.waitLoading()

            MsgBox("已完成 Profile Modify！", "Profile Modify Next", "T1 4096")
        }
    }

    static matchHistory(currentGuest) {
        CoordMode "Pixel", "Screen"
        CoordMode "Mouse", "Screen"

        loop {
            Sleep 100
            if (A_Index > 30) {
                MsgBox("界面定位失败", popupTitle, "T2 4096")
                utils.cleanReload(winGroup)
            }

            if (ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenWidth, this.AnchorImage)) {
                x := Number(FoundX) + 350
                y := Number(FoundY) + 80
                break
            } else {
                continue
            }
        }

        Send "!h" ; search
        utils.waitLoading()
        ; { ip - cancel the "save changes msgbox"
        Send "{Esc}"
        utils.waitLoading()
        ; }
        loop 12 {
            Send "{Tab}"
            Sleep 10
        }
        Send Format("{Text}{1}", currentGuest["idNum"])
        utils.waitLoading()
        Send "!h" ; search 
        utils.waitLoading()
        Sleep 500

        res := PixelGetColor(x, y)
        utils.waitLoading()

        return res
    }

    static parse(currentGuest) {
        parsedInfo := Map()
        ; alt Name
        parsedInfo["nameAlt"] := currentGuest["guestType"] = "国外旅客"
            ? " "
            : currentGuest["name"]
        ; last name
        parsedInfo["nameLast"] := currentGuest["guestType"] = "内地旅客"
            ? useDict.getFullnamePinyin(currentGuest["name"])[1]
            : currentGuest["nameLast"] = " "
                ? useDict.getFullnamePinyin(currentGuest["name"])[1]
                : currentGuest["nameLast"]
        ; first name
        parsedInfo["nameFirst"] := currentGuest["guestType"] = "内地旅客"
            ? useDict.getFullnamePinyin(currentGuest["name"])[2]
            : currentGuest["nameFirst"] = " "
                ? useDict.getFullnamePinyin(currentGuest["name"])[2]
                : currentGuest["nameFirst"] 
        ; address
        parsedInfo["addr"] := currentGuest["guestType"] = "内地旅客" 
            ? currentGuest["addr"]
            : " "
        ; language
        parsedInfo["language"] := currentGuest["guestType"] = "内地旅客"
            ? "C"
            : "E"
        ; country
        parsedInfo["country"] := currentGuest["guestType"] = "国外旅客"
            ? useDict.getCountryCode(currentGuest["country"])
            : "CN"
        ; province(mainland & hk/mo/tw)
        if (currentGuest["guestType"] = "内地旅客") {
            parsedInfo["province"] := useDict.getProvince(currentGuest["addr"])
        } else if (currentGuest["guestType"] = "港澳台旅客") {
            parsedInfo["province"] := useDict.getProvince(currentGuest["region"])
        } else {
            parsedInfo["province"] := " "
        }
        ; id number
        parsedInfo["idNum"] := currentGuest["idNum"]
        ; id Type
        parsedInfo["idType"] := useDict.getIdTypeCode(currentGuest["idType"])
        ; gender
        parsedInfo["gender"] := currentGuest["gender"] = "男" ? "Mr" : "Ms"
        ; birthday
        bd := StrSplit(currentGuest["birthday"], "-")
        parsedInfo["birthday"] := bd[2] . bd[3] . bd[1]
        ; tel number
        parsedInfo["tel"] := currentGuest["tel"]

        return parsedInfo
    }

    static fillAction(guestProfileMap) {
        CoordMode "Pixel", "Screen"
        AnchorImage := A_ScriptDir . "\src\Assets\AltNameAnchor.PNG"
        anchorX := 0
        anchorY := 0

        if (ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenWidth, AnchorImage)) {
            anchorX := FoundX - 10
            anchorY := FoundY
        } else {
            msgbox("not found", , "T1")
            return
        }

        WinSetAlwaysOnTop true, "ahk_class SunAwtFrame"
        CoordMode "Mouse", "Screen"
        BlockInput "SendAndMouse"
        ; { fillin common info: nameLast, nameFirst, language, gender, country, birthday, idType, idNum
        MouseMove anchorX, anchorY
        Click 3
        utils.waitLoading()
        Send Format("{Text}{1}", guestProfileMap["nameLast"])

        Send "{Tab}"
        utils.waitLoading()
        Send Format("{Text}{1}", guestProfileMap["nameFirst"])

        loop 2 {
            Send "{Tab}"
        }
        utils.waitLoading()
        Send Format("{Text}{1}", guestProfileMap["language"])

        Send "{Tab}"
        utils.waitLoading()
        Send Format("{Text}{1}", guestProfileMap["gender"])

        Send "{Tab}"
        utils.waitLoading()
        Send Format("{Text}{1}", guestProfileMap["addr"])

        loop 6 {
            Send "{Tab}"
        }
        utils.waitLoading()
        Send Format("{Text}{1}", guestProfileMap["country"])

        Send "{Tab}"
        utils.waitLoading()
        Send Format("{Text}{1}", guestProfileMap["province"])

        loop 9 {
            Send "{Tab}"
        }
        utils.waitLoading()
        Send Format("{Text}{1}", guestProfileMap["birthday"])

        Send "{Tab}"
        utils.waitLoading()
        Send Format("{Text}{1}", guestProfileMap["idNum"])
        utils.waitLoading()

        MouseMove anchorX + 393, anchorY + 28
        utils.waitLoading()
        Click 3
        Send Format("{Text}{1}", guestProfileMap["idType"])
        utils.waitLoading()
        Send "{Tab}"
        utils.waitLoading()

        if (guestProfileMap["tel"] != " ") {
            MouseMove anchorX + 270, anchorY + 110
            utils.waitLoading()
            Click 3
            Send "{Text}MOBILE"
            utils.waitLoading()
            Send "{Tab}"
            utils.waitLoading()
            Send Format("{Text}{1}", guestProfileMap["tel"])
            utils.waitLoading()
        }

        ; }
        if (guestProfileMap["nameAlt"] != " ") {
            ; { with hanzi name
            ; fillin: nameAlt, gender(in nameAlt window)
            MouseMove anchorX + 10, anchorY + 10 ; open alt name win
            utils.waitLoading()
            Click 1
            utils.waitLoading()

            Send Format("{Text}{1}", guestProfileMap["nameAlt"])
            utils.waitLoading()

            loop 3 {
                Send "{Tab}"
            }
            utils.waitLoading()
            Send Format("{Text}{1}", "C")

            Send "{Tab}"
            utils.waitLoading()
            Send Format("{Text}{1}", guestProfileMap["gender"])
            utils.waitLoading()
            Send "{Tab}"
            utils.waitLoading()
            Send "!o"
            utils.waitLoading()
        }
        BlockInput false
        WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"
    }
}