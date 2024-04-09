#Include "../ProfileModify/DictIndex.ahk"

class PMN_FillIn {
    static fill(currentGuest) {
        this.fillAction(this.parse(currentGuest))
    }

    static parse(currentGuest) {
        parsedInfo := Map()
        ; alt Name
        parsedInfo["nameAlt"] := currentGuest["guestType"] = "国外旅客"
            ? " "
            : currentGuest["name"]
        ; last name
        parsedInfo["nameLast"] := currentGuest["guestType"] = "内地旅客"
            ? getFullnamePinyin(currentGuest["name"])[1]
            : currentGuest["nameLast"]
        ; first name
        parsedInfo["nameFirst"] := currentGuest["guestType"] = "内地旅客"
            ? getFullnamePinyin(currentGuest["name"])[2]
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
            ? getCountryCode(currentGuest["country"])
            : "CN"
        ; address
        parsedInfo["addr"] := currentGuest["guestType"] = "内地旅客"
            ? currentGuest["addr"]
            : " "
        ; province(mainland & hk/mo/tw)
        if (currentGuest["guestType"] = "内地旅客") {
            parsedInfo["province"] := getProvince(currentGuest["addr"])
        } else if (currentGuest["guestType"] = "港澳台旅客") {
            parsedInfo["province"] := getProvince(currentGuest["region"])
        } else {
            parsedInfo["province"] := " "
        }
        ; id number
        parsedInfo["idNum"] := currentGuest["idNum"]
        ; id Type
        parsedInfo["idType"] := getIdTypeCode(currentGuest["idType"])
        ; gender
        parsedInfo["gender"] := currentGuest["gender"] = "男" ? "Mr" : "Ms"
        ; birthday
        bd := StrSplit(currentGuest["birthday"], "-")
        parsedInfo["birthday"] := bd[2] . bd[3] . bd[1]

        ; debug.mb(parsedInfo)

        return parsedInfo
    }

    static fillAction(guestProfileMap) {
        CoordMode "Pixel", "Screen"
        AnchorImage := A_ScriptDir . "\src\Assets\AltNameAnchor.PNG"
        anchorX := 0
        anchorY := 0

        if (WinGetMinMax("ahk_class SunAwtFrame") = 1) {
            anchorX := 451 - 10
            anchorY := 278
        } else if (ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, AnchorImage)) {
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
        Send Format("{Text}{1}", guestProfileMap["addr"])

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

        MsgBox("已完成 Profile Modify！", "Profile Modify Next", "OKCancel T2 4096")
    }
    
}