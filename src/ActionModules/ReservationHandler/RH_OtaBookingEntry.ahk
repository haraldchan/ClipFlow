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

    ; the initX, initY for USE() should be top-left corner of current booking window
    static USE(curResv, roomType, comment, pmsGuestNames, splitParty, initX := 193, initY := 182) {
        isCheckedIn := ImageSearch(&_, &_, 0, 0, A_ScreenWidth, A_ScreenHeight, A_ScriptDir . "\src\Assets\isCheckedIn.png")
        rateCode := match(curResv["agent"], {
            kingsley: "WHLRN",
            jielv: "WHLRN"
        })

        ; workflow start
        this.start()

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

        this.roomRatesEntry(rateCode, curResv["roomRates"], DateDiff(curResv["coDate"], curResv["ciDate"], "Days"), isCheckedIn)
        if (!this.isRunning) {
            msgbox("脚本已终止", popupTitle, "4096 T1")
            return
        }

        if (!curResv["bbf"].every(item => item == 0) && !comment.includes("CBF")) {
            this.breakfastEntry(curResv["bbf"])
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
        loop 5 {
            Send "{Esc}"
            utils.waitLoading()
        }
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
        loop 5 {
            Send "{Esc}"
            utils.waitLoading()
        }
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
        loop 3 {
            Send "{Esc}"
            utils.waitLoading()
        }
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
            loop 5 {
                Send "{Esc}"
                utils.waitLoading()
            }
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
        loop 5 {
            Send "{Esc}"
            utils.waitLoading()
        }
        utils.waitLoading()
    }


    static commentOrderIdEntry(orderId, comment, initX := 622, initY := 596) {
        MouseMove initX, initY ;622, 596
        utils.waitLoading()
        Click "Down"
        MouseMove initX + 518, initY + 9 ;1140, 605
        Sleep 100
        Click "Up"
        utils.waitLoading()
        Send Format("{Text}{1}", comment)
        utils.waitLoading()

        ; fill-in orderId
        MouseMove initX + 217, initY - 41 ;839, 555
        utils.waitLoading()
        Click "Down"
        MouseMove initX + 485, initY - 33 ;1107, 563
        Sleep 100
        Click "Up"
        utils.waitLoading()
        Send Format("{Text}{1}", orderId)
        utils.waitLoading()

        if (comment.includes("CBF")) {
            Send "{Tab}"
            utils.waitLoading()

            A_Clipboard := ""
            Send "^c"
            utils.waitLoading()
            Send "{Text}CBF," . A_Clipboard
            utils.waitLoading()
        }

        Send "{Tab}"
        utils.waitLoading()
        loop 5 {
            Send "{Esc}"
            utils.waitLoading()
        }
        utils.waitLoading()
    }

    static roomRatesEntry(rateCode, roomRates, nts, isCheckedIn, initX := 372, initY := 524) {

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
            loop 3 {
                Send "{Esc}"
                utils.waitLoading()
            }
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
            loop 5 {
                Send "{Esc}"
                utils.waitLoading()
            }
            utils.waitLoading()
            Send "!d"
            utils.waitLoading()
            loop roomRates.Length {
                index := A_Index
                Send "!e"
                utils.waitLoading()
                loop (isCheckedIn ? 4 : 6) {
                    Send "{Tab}"
                    utils.waitLoading()
                }
                Send "{Text}" . rateCode
                utils.waitLoading()
                loop 2 {
                    Send "{Tab}"
                    utils.waitLoading()
                    Send "{Esc}"
                    utils.waitLoading()
                }
                Send "{Text}" . roomRates[index]
                utils.waitLoading()
                Send "{Tab}"
                utils.waitLoading()
                Send "!o"
                utils.waitLoading()
                Send "{Down}"
            }
            utils.waitLoading()
            Send "!o"
            utils.waitLoading()
            ; Send "{Esc}"
            ; utils.waitLoading()
            ; Send "!o"
            utils.waitLoading()
            loop 5 {
                Send "{Esc}"
                utils.waitLoading()
            }
        }
    }


    static breakfastEntry(bbf, initX := 352, initY := 548) {
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
        ; Send "1"
        utils.waitLoading()
        loop 5 {
            Send "{Esc}"
            Sleep 100
        }

        utils.waitLoading()
    }


    ; WIP
    static saveBooking(initX, initY) {
        ;TODO: action: save modified booking, handle popups.

    }


    ; WIP
    static splitPartyEntry(guestNames, roomQty, initX := 456, initY := 482) {
        ;TODO: action: split party
        Send "!t"
        Sleep 100
        MouseMove initX, initY
        Sleep 100
        Send Click
        Sleep 100
        ; !s: Split; !a: Split All
        if (roomQty = 2) {
            Send "!s"
        } else {
            Send "!a"
        }
        Sleep 100
        ; Send "!r"
        ; Sleep 1000
    }
}