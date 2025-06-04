class PMN_FillIn {
    static AnchorImage := A_ScriptDir . "\src\Assets\AltNameAnchor.PNG"
    static ErrorImage := A_ScriptDir . "\src\Assets\error.PNG"
    static FOUND := "0x000080"
    static NOT_FOUND := "0x008080"
    static isRunning := false

    static start(config := {}) {
        c := useProps(config, {
            setOnTop: false,
            blockInput: false
        })

        this.isRunning := true
        HotIf (*) => this.isRunning
        Hotkey("F12", (*) => this.end(), "On")

        CoordMode "Pixel", "Screen"
        CoordMode "Mouse", "Screen"

        WinActivate "ahk_class SunAwtFrame"
        WinSetAlwaysOnTop c.setOnTop, "ahk_class SunAwtFrame"

        BlockInput c.blockInput
    }

    static end() {
        this.isRunning := false
        Hotkey("F12", "Off")

        WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"
        BlockInput false
    }

    static errorFallback() {
        Send "^c"
        utils.waitLoading()
        Send "{Space}"
        WinActivate "ahk_class SunAwtFrame"
        Sleep 300

        if (ImageSearch(&_, &_, 0, 0, A_ScreenWidth, A_ScreenWidth, this.ErrorImage)) {
            Send "!o"
            utils.waitLoading()
            Send "!c"
            utils.waitLoading()

            return true
        } else {
            Send "{BackSpace}"
            utils.waitLoading()
            Send "^v"
            utils.waitLoading()
            return false
        }
    }

    static fill(currentGuest, isOverwrite := false, keepGoing := false) {
        this.start({ setOnTop: true, blockInput: true })
        err := this.errorFallback()
        if (err) {
            this.end()
            return
        }

        guest := this.parse(currentGuest)

        ; force overwrite
        if (isOverwrite) {
            success := this.fillAction(guest)
            utils.waitLoading()
            if (success) {
                MsgBox("已完成 Profile Modify！", "Profile Modify Next", "T1 4096")
                Send "!o"
            }

            ( !keepGoing && this.end() )
            return
        }

        currentId := this.getCurrentId()
        ; on-screen profile matcheds
        if (currentId == guest["idNum"]) {
            MsgBox("当前 Profile 正确", "Profile Modify Next", "T1 4096")
            Sleep 100
            Send "!o"

            ( !keepGoing && this.end() )
            return
        }

        ; matched in database
        if (this.matchHistory(guest) == this.FOUND) {
            Send "!o"
            utils.waitLoading()
            MsgBox("已匹配原有 Profile", "Profile Modify Next", "T1 4096")
            Sleep 100
            Send "!o"

            ( !keepGoing && this.end() )
            return
        } else {
            Send "!c"
            utils.waitLoading()
            sleep 100
            if (currentId == "") {
                success := this.fillAction(guest)
            } else {
                Send "!n"
                utils.waitLoading()
                Send "{Esc}"
                utils.waitLoading()
                success := this.fillAction(guest)
            }

            utils.waitLoading()
            if (success) {
                MsgBox("已完成 Profile Modify！", "Profile Modify Next", "T1 4096")
                Sleep 100
                Send "!o"
            }
        }

        ( !keepGoing && this.end() )
    }

    static getCurrentId() {
        prevClip := A_Clipboard

        if (ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenWidth, this.AnchorImage)) {
            anchorX := FoundX - 10
            anchorY := FoundY
        } else {
            MsgBox("界面定位失败", popupTitle, "T2 4096")
            agent.abort()
            utils.cleanReload(winGroup)
        }

        MouseMove anchorX + 393, anchorY + 50
        utils.waitLoading()
        Click 2
        Sleep 200
        Send "^c"
        utils.waitLoading()
        Send "!s"
        utils.waitLoading()
        Send "{Enter}"
        utils.waitLoading()

        currentId := (A_Clipboard = prevClip || A_Clipboard = "") ? "" : A_Clipboard
        A_Clipboard := prevClip

        return currentId
    }

    static matchHistory(currentGuest) {
        loop {
            Sleep 100
            if (A_Index > 30) {
                MsgBox("界面定位失败", popupTitle, "T2 4096")
                agent.abort()
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

        Send "!h"
        utils.waitLoading()
        Send "{Esc}" ; cancel the "save changes msgbox"
        utils.waitLoading()
        if (!this.isRunning) {
            msgbox("脚本已终止", popupTitle, "4096 T1")
            return
        }

        loop 12 {
            Send "{Tab}"
            Sleep 10
        }

        if (!this.isRunning) {
            msgbox("脚本已终止", popupTitle, "4096 T1")
            return
        }

        Send Format("{Text}{1}", currentGuest["idNum"])
        utils.waitLoading()
        Send "!h"
        utils.waitLoading()
        Sleep 500

        if (!this.isRunning) {
            msgbox("脚本已终止", popupTitle, "4096 T1")
            return
        }

        res := PixelGetColor(x, y)
        utils.waitLoading()

        return res
    }

    static parse(currentGuest) {
        parsedInfo := Map()
        ; alt Name
        currentGuest["name"] := currentGuest["name"].replace("👤", "")
        parsedInfo["nameAlt"] := currentGuest["guestType"] == "国外旅客" ? " " : currentGuest["name"]

        ; last/firstname
        isTaiwanese := currentGuest["guestType"] == "港澳台旅客" && currentGuest["region"] == "台湾"
        if (currentGuest["guestType"] == "内地旅客" || isTaiwanese) {
            ; ethinic minority guests
            if (currentGuest["name"].includes("·")) {
                parsedInfo["nameLast"] := currentGuest["name"].split("·")[1].split("").map(hanzi => useDict.getPinyin(hanzi)).join(" ")
                parsedInfo["nameFirst"] := currentGuest["name"].split("·")[2].split("").map(hanzi => useDict.getPinyin(hanzi)).join(" ")
            } else {
                fullname := useDict.getFullnamePinyin(currentGuest["name"], isTaiwanese)
                parsedInfo["nameLast"] := fullname[1]
                parsedInfo["nameFirst"] := fullname[2]   
            }
        } else {
            parsedInfo["nameLast"] := currentGuest["nameLast"]
            parsedInfo["nameFirst"] := currentGuest["nameFirst"]
        }
        
        ; fallback for incomplete info
        if (currentGuest["idType"] == "港澳台居民居住证"
            && parsedInfo["nameLast"] == " "
        && parsedInfo["nameFirst"] == " ") {
            fullname := useDict.getFullnamePinyin(currentGuest["name"])
            parsedInfo["nameLast"] := fullname[1]
            parsedInfo["nameFirst"] := fullname[2]
        }
        
        ; address
        parsedInfo["addr"] := currentGuest["guestType"] == "内地旅客" ? currentGuest["addr"] : " "
        
        ; language
        parsedInfo["language"] := currentGuest["guestType"] == "内地旅客" ? "C" : "E"
        
        ; country
        parsedInfo["country"] := currentGuest["guestType"] == "国外旅客" ? useDict.getCountryCode(currentGuest["country"]) : "CN"
        
        ; province(mainland & hk/mo/tw)
        if (currentGuest["guestType"] == "内地旅客") {
            parsedInfo["province"] := currentGuest["idType"] == "身份证" 
                ? useDict.getProvinceById(currentGuest["idNum"])
                : useDict.getProvince(currentGuest["addr"])
        } else if (currentGuest["guestType"] == "港澳台旅客") {
            parsedInfo["province"] := useDict.getProvince(currentGuest["region"])
        } else {
            parsedInfo["province"] := " "
        }
        
        ; id number
        parsedInfo["idNum"] := currentGuest["idNum"]
        
        ; id Type
        parsedInfo["idType"] := useDict.getIdTypeCode(currentGuest["idType"])
        
        ; gender
        parsedInfo["gender"] := currentGuest["gender"] == "男" ? "Mr" : "Ms"
        
        ; birthday
        bd := StrSplit(currentGuest["birthday"], "-")
        parsedInfo["birthday"] := bd[2] . bd[3] . bd[1]
        
        ; tel number
        tel := currentGuest["tel"]
        if (StrLen(tel) == 11) {
            f := SubStr(tel, 1, 3)
            s := SubStr(tel, 4, 4)
            r := SubStr(tel, 8, 4)
            
            parsedInfo["tel"] := f . "-" . s . "-" . r
        } else {
            parsedInfo["tel"] := tel
        }
        
        return parsedInfo
    }
    
    static fillAction(guestProfileMap) {
        if (ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenWidth, this.AnchorImage)) {
            anchorX := FoundX - 10
            anchorY := FoundY
        } else {
            msgbox("not found", , "T1")
            return
        }

        MouseMove anchorX, anchorY
        Click 3
        utils.waitLoading()
        Send Format("{Text}{1}", guestProfileMap["nameLast"])

        Send "{Tab}"
        utils.waitLoading()

        ; check future reservation popup and resolve it
        if (PixelSearch(&_, &_, FoundX, FoundY, FoundX + 250, FoundY + 250, "0x000080")) {
            Send "!o"
            utils.waitLoading()
        }

        Send Format("{Text}{1}", guestProfileMap["nameFirst"])

        loop 2 {
            Send "{Tab}"
        }
        utils.waitLoading()
        Send Format("{Text}{1}", guestProfileMap["language"])

        if (!this.isRunning) {
            msgbox("脚本已终止", popupTitle, "4096 T1")
            return
        }

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

        if (!this.isRunning) {
            msgbox("脚本已终止", popupTitle, "4096 T1")
            return
        }

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

        if (!this.isRunning) {
            msgbox("脚本已终止", popupTitle, "4096 T1")
            return
        }

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

        return true
    }
}