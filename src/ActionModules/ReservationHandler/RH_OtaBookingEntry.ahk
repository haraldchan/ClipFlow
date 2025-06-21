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

    ; the initX, initY for USE() should be top-left corner of current booking window
    static USE(curResv, roomType, comment, pmsGuestNames, splitParty, packages, initX := 193, initY := 182) {
        rateCode := match(curResv["agent"], {
            kingsley: "WHLRN",
            jielv: match(curResv["bbf"][1], Map(
                x => x == 0, "WHJL",
                x => x == 1, "WHJB1",
                X => X == 2, "WHJB2"
            ))
        })

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

        this.routingEntry(curResv["agent"])
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

        this.commentOrderIdEntry(curResv["orderId"], comment)
        if (!this.isRunning) {
            msgbox("脚本已终止", popupTitle, "4096 T1")
            return
        }

        this.roomRatesEntry(rateCode, curResv["roomRates"], DateDiff(curResv["coDate"], curResv["ciDate"], "Days"), isCheckedIn, curResv["bbf"])
        if (!this.isRunning) {
            msgbox("脚本已终止", popupTitle, "4096 T1")
            return
        }

        if (!curResv["bbf"].every(item => item == 0) && !comment.includes("CBF")) {
            this.breakfastEntry(curResv["bbf"], curResv["roomRates"])
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
        utils.waitLoading()
    }


    static routingEntry(agent, initX := 895, initY := 218) {
        agent := match(agent, {
            kingsley: "Guangzhou Kingsley Business Consultant",
            jielv: "Shenzhen jielv holiday"
        })

        MouseMove initX, initY
        utils.waitLoading()
        Click 3
        utils.waitLoading()
        Send "{Delete}"
        utils.waitLoading()
        Send "!s"
        utils.waitLoading()
        loop 5 {
            Send "{Esc}"
            utils.waitLoading()
        }
        Click
        Send "{Text}" . agent
        utils.waitLoading()
        Send "!s"
        utils.waitLoading()
        Send "!o"
        utils.waitLoading()
        this.dismissPopup()
        Send "{Space}"
        utils.waitLoading()
        Send "!o"
        utils.waitLoading()
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


    static commentOrderIdEntry(orderId, comment, initX := 839, initY := 555) {
        ; fill-in orderId
        MouseMove initX, initY ; 839, 555
        utils.waitLoading()
        Click 3
        utils.waitLoading()
        Send Format("{Text}{1}", orderId)
        utils.waitLoading()
        Send "{Tab}"
        utils.waitLoading()

        ; send specials: CBF
        if (comment.includes("CBF")) {
            A_Clipboard := ""
            Send "^c"
            utils.waitLoading()
            Send "{Text}CBF," . A_Clipboard
            utils.waitLoading()
        }

        ; send comment
        Send "{Tab}"
        utils.waitLoading()
        Send Format("{Text}{1}", comment)
        utils.waitLoading()

        Send "{Tab}"
        utils.waitLoading()
        this.dismissPopup()
        utils.waitLoading()
    }

    static roomRatesEntry(rateCode, roomRates, nts, isCheckedIn, bbf, initX := 372, initY := 524) {
        ; mkt/src code
        if (!isCheckedIn) {
            MouseMove 636, 361
            utils.waitLoading()
            Click 3
            utils.waitLoading()
            Send "{Text}TRAVEL AGENT GTD"
            utils.waitLoading()
            Send "{Tab}"
            utils.waitLoading()
        } else {
            MouseMove 636, 381
            utils.waitLoading()
            Click 3
            utils.waitLoading()
        }
        Send "{Text}WHL"
        utils.waitLoading()
        Send "{Tab}"
        utils.waitLoading()
        Send "!y"
        utils.waitLoading()
        Send "{Text}WHO"
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
                if (bbf[1] == 2) {
                    MouseMove FoundX + 143, FoundY + 69
                    Click 3
                    Send "{Text}2"
                    utils.waitLoading()
                }

                MouseMove FoundX + 226, FoundY + 142
                Click 3
                Send "{Text}" . rateCode
                utils.waitLoading()

                MouseMove FoundX + 176, FoundY + 165
                Click 3
                Send "{Text}" . roomRates[A_Index]

                Send "!o"
                utils.waitLoading()
                Send "{Down}"
                utils.waitLoading()
            }
            utils.waitLoading()
            Send "!o"
            utils.waitLoading()
            this.dismissPopup()
        }
    }

    static breakfastEntry(bbf, roomRates, initX := 352, initY := 548) {
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

        ; change "Adults"
        MouseMove initX - 67, initY - 124 ; 285, 424
        utils.waitLoading()
        Click 3
        Send Format("{Text}{1}", bbf[1])
        utils.waitLoading()

        this.dismissPopup()
    }

    static packageEntry(package, initX := 352, initY := 548) {
        ;entry bbf package
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

    static splitPartyEntry(guestNames, roomQty, initX := 456, initY := 482) {
        ;TODO: action: split party
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
        for guestName in guestNames {
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
