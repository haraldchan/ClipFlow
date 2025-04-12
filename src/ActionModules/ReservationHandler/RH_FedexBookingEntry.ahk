class FedexBookingEntry {
    static AnchorImage := A_ScriptDir . "\src\Assets\opera-active-win.PNG"
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


    static USE(infoObj, index := 1, bringForwardTime := 10, initX := 194, initY := 183) {
        schdCiDate := infoObj["ciDate"]
        schdCoDate := infoObj["coDate"]

        pmsCiDate := StrSplit(infoObj["ETA"], ":")[1] < bringForwardTime
            ? DateAdd(schdCiDate, -1, "days")
            : schdCiDate
        pmsCoDate := schdCoDate
        pmsNts := DateDiff(pmsCoDate, pmsCiDate, "days")
        ; reformat to match pms date format
        schdCiDate := FormatTime(schdCiDate, "MMddyyyy")
        schdCoDate := FormatTime(schdCoDate, "MMddyyyy")
        pmsCiDate := FormatTime(pmsCiDate, "MMddyyyy")
        pmsCoDate := FormatTime(pmsCoDate, "MMddyyyy")

        ; workflow start
        this.start()

        this.profileEntry(infoObj["crewNames"], index)
        if (!this.isRunning) {
            msgbox("脚本已终止", popupTitle, "4096 T1")
            return
        }
        
        this.dateTimeEntry(pmsCiDate, pmsCoDate, infoObj["ETA"], infoObj["ETD"])
        if (!this.isRunning) {
            msgbox("脚本已终止", popupTitle, "4096 T1")
            return
        }

        this.moreFieldsEntry(schdCiDate, schdCoDate, infoObj["ETA"], infoObj["ETD"], infoObj["flightIn"], infoObj["flightOut"])
        if (!this.isRunning) {
            msgbox("脚本已终止", popupTitle, "4096 T1")
            return
        }

        this.commentEntry(infoObj)
        if (!this.isRunning) {
            msgbox("脚本已终止", popupTitle, "4096 T1")
            return
        }

        if (infoObj["daysActual"] < pmsNts) {
            this.dailyDetailsEntry(infoObj["daysActual"])
            if (!this.isRunning) {
                msgbox("脚本已终止", popupTitle, "4096 T1")
                return
            }
        }

        ; post Alert reminder when room charge needs to be post manually
        if (infoObj["daysActual"] > pmsNts) {
            this.postRoomChargeAlertEntry(pmsNts, infoObj["daysActual"])
            if (!this.isRunning) {
                msgbox("脚本已终止", popupTitle, "4096 T1")
                return
            }
        }

        this.crsNumEntry(infoObj["tracking"])
        if (!this.isRunning) {
            msgbox("脚本已终止", popupTitle, "4096 T1")
            return
        }

        this.end()
    }

    static profileEntry(crewNames, index, initX := 471, initY := 217) {
        crewName := StrSplit(crewNames[index], " ")

        ; open profile
        loop 10 {
            if (ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenWidth, this.AnchorImage)) {
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

        ; MouseMove initX, initY ; 471, 217
        ; Click
        ; Sleep 3000
        MouseMove initX - 91, initY + 338 ; 380, 555 ; search existing profile
        utils.waitLoading()
        Click
        utils.waitLoading()
        Send Format("{Text}{1}", crewName[2])
        utils.waitLoading()
        Send "{Tab}"
        utils.waitLoading()
        Send Format("{Text}{1}", crewName[1])
        utils.waitLoading()
        Send "{Tab}"
        utils.waitLoading()

        ; check profile existence
        CoordMode "Pixel", "Screen"
        if (PixelGetColor(initX + 109, initY + 288) != "0x0000FF") { ; profile is found 580, 505
            Send "{Enter}"
            utils.waitLoading()
        } else { ; profile not found, create a new one
            Send "{Enter}"
            utils.waitLoading()
            Send "!n"
            utils.waitLoading()
            Send "{Esc}"
            utils.waitLoading()
            MouseMove initX - 39, initY + 68 ; 432, 285
            utils.waitLoading()
            Click 3
            utils.waitLoading()
            Send Format("{Text}{1}", crewName[2])
            MouseMove initX - 72, initY + 95 ; 399, 312
            utils.waitLoading()
            Click 3
            utils.waitLoading()
            Send Format("{Text}{1}", crewName[1])
            utils.waitLoading()
        }
        Send "!o"
        utils.waitLoading()
    }

    static dateTimeEntry(checkin, checkout, ETA, ETD, initX := 323, initY := 506) {
        ; fill-in checkin/checkout
        MouseMove 345, initY - 150 ; 332, 356
        utils.waitLoading()
        Click 1
        utils.waitLoading()
        Send "!c"
        utils.waitLoading()
        Send Format("{Text}{1}", checkin)
        utils.waitLoading()
        MouseMove initX + 2, initY - 108 ; 325, 398
        utils.waitLoading()
        Click
        loop 5 {
            Send "{Esc}"
            utils.waitLoading()
        }
        MouseMove 345, initY - 101 ; 335, 405
        utils.waitLoading()
        Click 1
        utils.waitLoading()
        Send "!c"
        utils.waitLoading()
        Send Format("{Text}{1}", checkout)
        utils.waitLoading()
        Send "{Enter}"
        utils.waitLoading()
        loop 5 {
            Send "{Esc}"
            utils.waitLoading()
        }
        ; fill in ETA & ETD
        MouseMove 320, 599
        utils.waitLoading()
        Click 3
        utils.waitLoading()

        ; check if resv is checked-in already
        prevClb := A_Clipboard
        Send "^c"
        if (A_Clipboard != prevClb) {
            Send Format("{Text}{1}", ETA)
            utils.waitLoading()
            Send "{Tab}"
            utils.waitLoading()
        }

        MouseMove 454, 599
        utils.waitLoading()
        Click 3
        utils.waitLoading()
        Send Format("{Text}{1}", ETD)
        Send "{Tab}"
        utils.waitLoading()
    }

    static commentEntry(infoObj, initX := 622, initY := 589) {
        comment := ""

        ; select current comment
        MouseMove initX, initY ; 622, 596
        utils.waitLoading()
        Click "Down"
        MouseMove initX + 518, initY + 36 ; 1140, 605
        utils.waitLoading()
        Click "Up"
        utils.waitLoading()
        Send "^x"
        utils.waitLoading()

        ; set new comment
        if (infoObj["resvType"] == "ADD") {
            comment := Format("RM INCL 1BBF TO CO,Hours@Hotel: {1}={2}day(s), ActualStay: {3}-{4}", infoObj["stayHours"], infoObj["daysActual"], infoObj["ciDate"], infoObj["coDate"])
        } else {
            prevComment := A_Clipboard
            comment := Format("Changed to {1}={2}day(s), New Stay:{3}-{4} // Before Update:{5}", infoObj["stayHours"], infoObj["daysActual"], infoObj["ciDate"], infoObj["coDate"], prevComment)
        }

        utils.waitLoading()
        Send Format("{Text}{1}", comment)
        utils.waitLoading()

        ; fill-in new flight and trip
        MouseMove initX + 307, initY - 35 ; 929, 554
        utils.waitLoading()
        Click 3
        utils.waitLoading()
        Send Format("{Text}{1}  {2}", infoObj["flightIn"], infoObj["tripNum"])
        utils.waitLoading()
    }

    static moreFieldsEntry(sCheckin, sCheckout, ETA, ETD, flightIn, flightOut, initX := 236, initY := 333) {
        MouseMove initX, initY ; 236, 333
        utils.waitLoading()
        Click
        utils.waitLoading()
        MouseMove 680, 460
        utils.waitLoading()
        Click 2
        utils.waitLoading()
        Send Format("{Text}{1}", flightIn)
        utils.waitLoading()
        loop 2 {
            Send "{Tab}"
            utils.waitLoading()
        }

        Send Format("{Text}{1}", sCheckin)
        Sleep 100
        Send "{Tab}"
        utils.waitLoading()
        Send Format("{Text}{1}", ETA)
        utils.waitLoading()
        MouseMove 917, 465
        utils.waitLoading()
        Click 2
        utils.waitLoading()
        Send Format("{Text}{1}", flightOut)
        utils.waitLoading()
        loop 2 {
            Send "{Tab}"
            utils.waitLoading()
        }
        utils.waitLoading()
        Send Format("{Text}{1}", sCheckout)
        utils.waitLoading()
        Send "{Tab}"
        utils.waitLoading()
        Send Format("{Text}{1}", ETD)
        utils.waitLoading()
        MouseMove initX + 605, initY + 347 ; 841, 680
        utils.waitLoading()
        Click
        utils.waitLoading()
    }

    static dailyDetailsEntry(daysActual, initX := 372, initY := 524) {
        MouseMove initX, initY ; 372, 524
        utils.waitLoading()
        Click
        utils.waitLoading()
        Send "!d"
        utils.waitLoading()
        loop daysActual {
            Send "{Down}"
            utils.waitLoading()
        }
        Send "!e"
        utils.waitLoading()
        loop {
            Send "{Tab}"
            utils.waitLoading()
            Send "^c"
            utils.waitLoading()
            if (A_Clipboard == "FEDEXN")
            break
        }
        Send "{Text}NRR"
        utils.waitLoading()
        Send "!o"
        utils.waitLoading()
        loop 3 {
            Send "{Esc}"
            utils.waitLoading()
        }
        utils.waitLoading()
        Send "!o"
        utils.waitLoading()
        loop 5 {
            Send "{Esc}"
            utils.waitLoading()
        }
        utils.waitLoading()
    }

    static postRoomChargeAlertEntry(pmsNts, daysActual, initX := 759, initY := 266) {
        Send "!t"
        MouseMove initX, initY ; 759, 266
        utils.waitLoading()
        Click
        Send "!n"
        utils.waitLoading()
        Send "{Text}OTH"
        MouseMove initX - 242, initY + 133 ; 517, 399
        utils.waitLoading()
        Click
        MouseMove initX - 280, initY + 169 ; 479, 435
        utils.waitLoading()
        Click
        MouseMove initX - 70, initY + 211 ; 689, 477
        utils.waitLoading()
        Click "Down"
        MouseMove initX - 62, initY + 211 ; 697, 477
        utils.waitLoading()
        Click "Up"
        utils.waitLoading()
        Send Format("{Text}实际需收取 {1} 晚房费。退房请补入 {2} 晚房费。", daysActual, daysActual - pmsNts)
        utils.waitLoading()
        Send "!o"
        utils.waitLoading()
        Send "!c"
        utils.waitLoading()
        Send "!c"
        utils.waitLoading()
    }

    static crsNumEntry(tracking, initX := 739, initY := 505) {
        MouseMove initX, initY
        utils.waitLoading()
        Click
        utils.waitLoading()
        Send "!n"
        utils.waitLoading()
        MouseMove initX - 29, initY - 99
        utils.waitLoading()
        Click
        utils.waitLoading()
        Send "{Down}"
        utils.waitLoading()
        Send "!o"
        utils.waitLoading()
        Send Format("{Text}{1}", tracking)
        utils.waitLoading()
        Send "!o"
        utils.waitLoading()

        if (ImageSearch(&_, &_, 0, 0, A_ScreenWidth, A_ScreenHeight, A_ScriptDir . "\src\Assets\error.PNG")) {
            Send "!o"
            utils.waitLoading()
            Send "!c"
            utils.waitLoading()
            Send "{Esc}"
            utils.waitLoading()
            Send "!e"
            utils.waitLoading()
            Send "{Tab}"
            utils.waitLoading()
            Send "^{Right}"
            utils.waitLoading()
            Send "{Text}" . "\" . tracking
            utils.waitLoading()
            Send "!o"
        }


        Send "!c"
        utils.waitLoading()
    }
}