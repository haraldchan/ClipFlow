class RH_OtaBookingEntry {
    static profileAnchorImage := A_ScriptDir . "\src\Assets\opera-active-win.PNG"
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

    static dismissPopup() {
        loop {
            if (
                ImageSearch(&_, &_, 0, 0, A_ScreenWidth, A_ScreenHeight, A_ScriptDir . "\src\Assets\alert.png")
                || ImageSearch(&_, &_, 0, 0, A_ScreenWidth, A_ScreenHeight, A_ScriptDir . "\src\Assets\info.png")
            ) {
                Send "{Escape}"
                utils.waitLoading()
                Sleep 200
            } else {
                utils.waitLoading()
                break
            }
        }
    }

    static getRequests(remarks) {
        requestMap := Map(
            "NSR", ["无烟", "不抽烟", "烟味"],
            "SMR", ["吸烟", "可以抽烟"],
            "QRM", ["静"],
            "ADJ", ["相邻", "隔壁"],
            "SFL", ["同楼层", "同层"],
            "HFR", ["高层", "高楼层"],
            "AER", ["远离电梯"],
            "NER", ["近电梯"]
        )

        requests := []
        for special, keywords in requestMap {
            for keyword in keywords {
                if (remarks.includes(keyword)) {
                    requests.Push(special)
                    break
                }
            }
        }

        return requests.join(",")
    }

    ; the initX, initY for USE() should be top-left corner of current booking window
    static USE(curResv, roomType, comment, pmsGuestNames, splitParty, packages, configFields, sendTrace) {
        rateCode := configFields["ratecode"][curResv["bbf"] + 1]
        if (!rateCode) {
            rateCode := configFields["ratecode"][1]
        }

        ; workflow start
        this.start()
        isCheckedIn := ImageSearch(&_, &_, 0, 0, A_ScreenWidth, A_ScreenHeight, A_ScriptDir . "\src\Assets\isCheckedIn.png")

        if (!isCheckedIn) {
            this.profileEntry(pmsGuestNames[1])
            if (!this.isRunning) {
                msgbox("脚本已终止", popupTitle, "4096 T1")
                return
            }

            this.roomQtyEntry(curResv["roomQty"])
            if (!this.isRunning) {
                msgbox("脚本已终止", popupTitle, "4096 T1")
                return
            }
        }

        this.routingEntry(curResv["payment"], configFields)
        if (!this.isRunning) {
            msgbox("脚本已终止", popupTitle, "4096 T1")
            return
        }

        this.roomTypeEntry(roomType, isCheckedIn)
        if (!this.isRunning) {
            msgbox("脚本已终止", popupTitle, "4096 T1")
            return
        }

        this.dateTimeEntry(curResv["ciDate"], curResv["coDate"], isCheckedIn)
        if (!this.isRunning) {
            msgbox("脚本已终止", popupTitle, "4096 T1")
            return
        }

        this.commentOrderIdSpecialEntry(curResv["orderId"], comment, curResv["remarks"])
        if (!this.isRunning) {
            msgbox("脚本已终止", popupTitle, "4096 T1")
            return
        }

        this.roomRatesEntry(
            rateCode, 
            curResv["roomRates"], 
            DateDiff(curResv["coDate"], curResv["ciDate"], "Days"), 
            isCheckedIn, 
            curResv["bbf"], 
            configFields
        )
        if (!this.isRunning) {
            msgbox("脚本已终止", popupTitle, "4096 T1")
            return
        }

        if (curResv["bbf"] && !comment.includes("CBF")) {
            this.breakfastEntry(curResv["bbf"], rateCode != configFields["ratecode"][1] || rateCode == "CORS")
            if (!this.isRunning) {
                msgbox("脚本已终止", popupTitle, "4096 T1")
                return
            }
        }

        if (packages) {
            packages.split(" ").map(package => this.packageEntry(package))
            if (!this.isRunning) {
                msgbox("脚本已终止", popupTitle, "4096 T1")
                return
            }
        }

        if (sendTrace) {
            this.traceEntry(curResv["remarks"])
            if (!this.isRunning) {
                msgbox("脚本已终止", popupTitle, "4096 T1")
                return
            }
        }

        if (splitParty) {
            this.splitPartyEntry(pmsGuestNames, curResv["roomQty"])
            if (!this.isRunning) {
                msgbox("脚本已终止", popupTitle, "4096 T1")
                return
            }
        }

        MsgBox("Completed.", "Reservation Handler", "T1 4096")
    }


    static profileEntry(guestName, initX := 471, initY := 217) {
        ; open profile
        loop 10 {
            if (ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenWidth, this.profileAnchorImage)) {
                anchorX := FoundX + 270
                anchorY := FoundY + 36
                break
            }
            Sleep 100
        }
        MouseMove anchorX, anchorY
        utils.waitLoading()
        Click
        utils.waitLoading()
        ; MouseMove initX, initY ;471, 217
        ; Click
        utils.waitLoading()
        Send "!n"
        utils.waitLoading()
        MouseMove initX - 39, initY + 68 ;432, 285
        utils.waitLoading()
        Click 3
        utils.waitLoading()
        Send Format("{Text}{1}", guestName[1])
        utils.waitLoading()
        MouseMove initX - 72, initY + 95 ;399, 312
        utils.waitLoading()
        Click 3
        utils.waitLoading()
        Send Format("{Text}{1}", guestName[2])
        utils.waitLoading()
        if (guestName.Length == 3) {
            MouseMove initX - 17, initY + 67 ; 454, 284
            utils.waitLoading()
            Click 3
            ; utils.waitLoading()
            Send Format("{Text}{1}", guestName[3])
            utils.waitLoading()
            Send "!o"
        }
        utils.waitLoading()
        Send "!o"
        utils.waitLoading()
        this.dismissPopup()
    }


    static roomQtyEntry(roomQty, initX := 294, initY := 441) {
        MouseMove initX, initY
        utils.waitLoading()
        Click 3
        utils.waitLoading()
        Send Format("{Text}{1}", roomQty)
        utils.waitLoading()
        Send "{Tab}"
        utils.waitLoading()
        this.dismissPopup()
    }


    static routingEntry(payment, configFields, initX := 895, initY := 218) {
        ; clear fields: Agent, Company
        MouseMove initX, initY
        utils.waitLoading()
        Click 3
        utils.waitLoading()
        Send "{Delete}"
        utils.waitLoading()
        Send "{Tab}"
        utils.waitLoading()
        Send "{Delete}"
        utils.waitLoading()
        Send "!s"
        utils.waitLoading()
        this.dismissPopup()
        
        if (configFields["profileType"] == "Travel Agent") {
            MouseMove initX, initY
        } else {
            MouseMove initX, initY + 20
        }

        utils.waitLoading()
        Click
        utils.waitLoading()
        Send "{Text}" . (payment.includes("现付") ? configFields["profileNamePoa"] : configFields["profileName"])
        utils.waitLoading()
        Send "!s"
        utils.waitLoading()
        Send "!o"
        utils.waitLoading()
        this.dismissPopup()

        ; check if default routing exist
        if (PixelGetColor(585, 388) == "0x000080") {
            Send "{Space}"
            utils.waitLoading()
            Send "!o"
            utils.waitLoading()
        } else if (payment.includes("预付")) {
            Send "!t"
            utils.waitLoading()
            Send "!i"
            utils.waitLoading()
            Send "!w"
            utils.waitLoading()
            loop 9 {
                Send "{Tab}"
                Sleep 100
            }
            Send "{Text}" . configFields["profileName"]
            utils.waitLoading()
            Send "{Enter}"
            utils.waitLoading()
            this.dismissPopup()
            loop 4 {
                Send "{Tab}"
                Sleep 100
            }
            Send "!o"
            utils.waitLoading()
            Send "!o"
            utils.waitLoading()
            Send "!c"
            utils.waitLoading()
            Send "!c"
            utils.waitLoading()
            this.dismissPopup()
        }
    }


    static roomTypeEntry(roomType, isCheckedIn, initX := 472, initY := 465) {
        MouseMove 500, 469 ; RTC btn
        utils.waitLoading()
        Click
        utils.waitLoading()
        Send Format("{Text}{1}", roomType)
        utils.waitLoading()
        Send "!o"
        utils.waitLoading()
        this.dismissPopup()
        if (!isCheckedIn) {
            MouseMove 350, 469 ; Room Type btn
            utils.waitLoading()
            Click
            utils.waitLoading()
            Send Format("{Text}{1}", roomType)
            utils.waitLoading()
            Send "!o"
            utils.waitLoading()
            loop 3 {
                Send "{Esc}"
                utils.waitLoading()
            }
        }
        utils.waitLoading()
    }


    static dateTimeEntry(checkin, checkout, isCheckedIn, initX := 332, initY := 356) {
        pmsCiDate := FormatTime(checkin, "MMddyyyy")
        pmsCoDate := FormatTime(checkout, "MMddyyyy")

        if (!isCheckedIn) {
            MouseMove 349, 363
            utils.waitLoading()
            Click
            utils.waitLoading()
            Send "!c"
            utils.waitLoading()
            Send Format("{Text}{1}", pmsCiDate)
            utils.waitLoading()
            Send "{Tab}"
            utils.waitLoading()
            this.dismissPopup()
        }

        MouseMove 350, 404
        utils.waitLoading()
        Click
        utils.waitLoading()
        Send "!c"
        utils.waitLoading()
        Send Format("{Text}{1}", pmsCoDate)
        utils.waitLoading()
        Send "{Enter}"
        utils.waitLoading()
        this.dismissPopup()
        utils.waitLoading()
    }


    static commentOrderIdSpecialEntry(orderId, comment, remarks, initX := 839, initY := 555) {
        ; fill-in orderId
        MouseMove initX, initY ; 839, 555
        utils.waitLoading()
        Click 3
        utils.waitLoading()
        Send Format("{Text}{1}", orderId)
        utils.waitLoading()
        Send "{Tab}"
        utils.waitLoading()

        A_Clipboard := ""
        Send "^c"
        Sleep 100

        specials := (comment.includes("CBF") ? "CBF," : "") . this.getRequests(remarks) . (!A_Clipboard ? "" : "," . A_Clipboard)
        Send "{Text}" . specials
        utils.waitLoading()

        ; send comment
        Send "{Tab}"
        utils.waitLoading()
        this.dismissPopup()
        Send Format("{Text}{1}", comment)
        utils.waitLoading()

        Send "{Tab}"
        utils.waitLoading()
        this.dismissPopup()
        utils.waitLoading()
    }

    static roomRatesEntry(rateCode, roomRates, nts, isCheckedIn, bbf, configFields, initX := 372, initY := 524) {
        ; mkt/src code
        if (!isCheckedIn) {
            MouseMove 636, 361
            utils.waitLoading()
            Click 3
            utils.waitLoading()
            Send "{Text}" . configFIelds["resType"]
            utils.waitLoading()
            Send "{Tab}"
            utils.waitLoading()
        } else {
            MouseMove 636, 381
            utils.waitLoading()
            Click 3
            utils.waitLoading()
        }
        Send "{Text}" . configFields["market"]
        utils.waitLoading()
        Send "{Tab}"
        utils.waitLoading()
        Send "!y"
        utils.waitLoading()
        Send "{Text}" . configFields["source"]
        utils.waitLoading()
        Send "{Tab}"
        utils.waitLoading()

        if (nts == 1 || roomRates.every(rate => rate == roomRates[1])) {
            MouseClickDrag "left", 325, 506, 256, 506
            utils.waitLoading()
            Send "{Text}" . rateCode
            utils.waitLoading()
            Send "{Tab}"
            utils.waitLoading()
            this.dismissPopup()
            Send "{Text}" . roomRates[1]
            utils.waitLoading()
            Send "{Tab}"
            utils.waitLoading()
            this.dismissPopup()
        } else {
            ; daily details
            MouseMove initX, initY ;372, 504
            utils.waitLoading()
            Click
            utils.waitLoading()
            this.dismissPopup()
            utils.waitLoading()
            Send "!d"
            utils.waitLoading()
            loop roomRates.Length {
                Send "!e"
                utils.waitLoading()

                ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenWidth, A_ScriptDir . "\src\Assets\opera-active-win.png")
                if (bbf > 1) {
                    MouseMove FoundX + 143, FoundY + 69
                    Click 3
                    Send "{Text}" . bbf
                    utils.waitLoading()
                    this.dismissPopup()
                }

                MouseMove FoundX + 226, FoundY + 142
                Click 3
                Send "{Text}" . rateCode
                utils.waitLoading()
                Send "{Tab}"
                utils.waitLoading()
                this.dismissPopup()

                MouseMove FoundX + 176, FoundY + 165
                Click 3
                Send "{Text}" . roomRates[A_Index]
                utils.waitLoading()
                Send "{Tab}"
                utils.waitLoading()
                this.dismissPopup()

                Send "!o"
                utils.waitLoading()
                Send "{Down}"
                utils.waitLoading()
            }
            utils.waitLoading()
            Send "!o"
            utils.waitLoading()
        }
        this.dismissPopup()
    }

    static breakfastEntry(bbf, packageBounded, initX := 352, initY := 548) {
        ; if ratecode is bound with packages(blue text), skip adding BFNP
        if (!packageBounded) {
            ;entry bbf package
            MouseMove initX, initY
            utils.waitLoading()
            Click
            utils.waitLoading()
            Send "!n"
            utils.waitLoading()
            Send "{Text}BFNP"
            utils.waitLoading()
            Send "!o"
            utils.waitLoading()
            Send "!o"
            utils.waitLoading()
            Send "{Esc}"
            utils.waitLoading()
        }

        ; change "Adults"
        MouseMove initX - 67, initY - 124 ; 285, 424
        utils.waitLoading()
        Click 3
        Send "{Text}" . bbf
        utils.waitLoading()
        Send "{Tab}"
        utils.waitLoading()
        this.dismissPopup()
    }

    static packageEntry(package, initX := 352, initY := 548) {
        ;entry extra package
        MouseMove initX, initY
        utils.waitLoading()
        Click
        utils.waitLoading()
        Send "!n"
        utils.waitLoading()
        Send "{Text}" . package
        utils.waitLoading()
        Send "!o"
        utils.waitLoading()
        Send "!o"
        utils.waitLoading()
        Send "{Esc}"
        utils.waitLoading()
        this.dismissPopup()
    }

    static traceEntry(traceText) {
        Send "!t"
        utils.waitLoading()
        Send "!t"
        utils.waitLoading()
        loop 3 {
            Send "{Tab}"
            Sleep 100
        }
        Send "{Text}FD"
        Sleep 100
        Send "{Tab}"
        utils.waitLoading()
        Send "{Text}" . traceText
        utils.waitLoading()
        Send "!o"
        utils.waitLoading()
        Send "!c"
        utils.waitLoading()
        Send "!c"
        utils.waitLoading()
    }

    static splitPartyEntry(guestNames, roomQty, initX := 456, initY := 482) {
        Send "!t"
        utils.waitLoading()
        Send "{Text}party"
        utils.waitLoading()
        ; !s: Split; !a: Split All
        if (roomQty == 2) {
            Send "!s"
        } else {
            Send "!a"
        }
        utils.waitLoading()

        ; Fill guest names
        loop roomQty {
            guestName := A_Index > guestNames.Length ? guestNames[1] : guestNames[A_Index]
            if (A_Index == 1) {
                Send "{Down}"
                utils.waitLoading()
                continue
            }
            Send "!r"
            utils.waitLoading()
            this.profileEntry(guestName)
            utils.waitLoading()
            Send "!o"
            utils.waitLoading()
            Send "{Down}"
            Sleep 500
        }

        Send "!o"
        utils.waitLoading()
    }
}