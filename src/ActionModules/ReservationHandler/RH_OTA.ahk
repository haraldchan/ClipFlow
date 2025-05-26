class RH_OTA {
    static USE(curResv, splitParty := false) {
        if (curResv["agent"] == "kingsley") {
            this.RH_Kingsley(curResv, splitParty)
        }

    }

    static RH_Kingsley(curResv, splitParty) {
        ; convert roomType
        roomTypeRef := Map(
            "标准大床房",       "SKC",
            "标准双床房",       "STC",
            "豪华城景大床房",    "DKC",
            "豪华城景双床房",    "DTC",
            "豪华江景大床房",    "DKR",
            "豪华江景双床房",    "DTR",
            "行政豪华城景大床房", "CKC",
            "行政豪华城景双床房", "CTC",
            "行政豪华江景大床房", "CKR",
            "行政豪华江景双床房", "CTR",
            "行政尊贵套房",      "CSK"
        )    
        roomType := roomTypeRef[curResv["roomType"]]
    
        ; define breakfast comment
        breakfastType := (SubStr(roomType, 1, 1) = "C") ? "CBF" : "BBF"
        breakfastQty := curResv["bbf"][1]
        comment := (breakfastQty == 0)
            ? "RM TO TA"
            : Format("RM INCL {1}{2} TO TA", breakfastQty, breakfastType)
    
        ; reformat guest names
        pmsGuestNames := []
        loop curResv["guestNames"].Length {
            curGuestName := curResv["guestNames"][A_Index]
            if (RegExMatch(curGuestName, "^[a-zA-Z/]+$") > 0) {
                ; if only includes English alphabet, push [lastName, firstName]
                pmsGuestNames.Push(StrSplit(curGuestName, "/"))
            } else {
                pmsGuestNames.Push([
                    useDict.getFullnamePinyin(curGuestName)[1], ; lastName pinyin
                    useDict.getFullnamePinyin(curGuestName)[2], ; firstName pinyin
                    curGuestName, ; hanzi-name
                ])
            }
        }
    
        ; Main booking modification
        RH_OtaBookingEntry.USE(
            curResv,
            roomType,
            comment,
            pmsGuestNames,
            splitParty
        )
    }
}

class RH_OtaBookingEntry {
    ; the initX, initY for USE() should be top-left corner of current booking window
    static USE(curResv, roomType, comment, pmsGuestNames, splitParty, initX := 193, initY := 182) {
        isCheckedIn := ImageSearch(&_, &_, 0, 0, A_ScreenWidth, A_ScreenHeight, A_ScriptDir . "\src\Assets\isCheckedIn.png")
        rateCode := "WHLRN"

        if (!isCheckedIn) {
            ; this.profileEntry(pmsGuestNames[1])

            this.roomQtyEntry(curResv["roomQty"])
        }

        this.routingEntry(curResv["agent"])

        this.roomTypeEntry(roomType, isCheckedIn)

        this.dateTimeEntry(curResv["ciDate"], curResv["coDate"], isCheckedIn)

        this.commentOrderIdEntry(curResv["orderId"], comment)

        this.roomRatesEntry(rateCode, curResv["roomRates"], isCheckedIn)

        if (!curResv["bbf"].every(item => item == 0)) {
            this.breakfastEntry(curResv["bbf"])
        }

        if (splitParty) {
            this.splitPartyEntry(pmsGuestNames, curResv["roomQty"])
        }

        MsgBox("Completed.", "Reservation Handler", "T1 4096")
    }

    static profileEntry(guestName, initX := 471, initY := 217) {
        MouseMove initX, initY ;471, 217
        Click
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
        Send "{Tab}"
        utils.waitLoading()
        loop 5 {
            Send "{Esc}"
            utils.waitLoading()
        }
        utils.waitLoading()
    }

    static roomRatesEntry(rateCode, roomRates, isCheckedIn, initX := 372, initY := 524) {
        ; ratecode 
        MouseClickDrag "left", 326, 510, 260, 510
        utils.waitLoading()
        Send "{Text}" . rateCode
        utils.waitLoading()
        Send "{Tab}"
        loop 5 {
            Send "{Esc}"
            utils.waitLoading()
        }

        ; mkt/src code
        MouseMove 646, 380
        utils.waitLoading()
        Click 3
        utils.waitLoading()
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
                utils.waitLoading()
                Send "{Tab}"       
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

    static breakfastEntry(bbf, initX := 352, initY := 548) {
        trayTip "录入中：早餐"
        Sleep 100
        
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

    static routingEntry(agent, initX := 895, initY := 218) {
        A_Clipboard := ""
        agent := matchCase(agent, {
            kingsley: "Guangzhou Kingsley Business Consultant",
            jielv: "Shenzhen jielv holiday"
        })

        MouseMove initX, initY
        utils.waitLoading()
        Click 3
        utils.waitLoading()
        Send "^c"
        utils.waitLoading()

        if (!A_Clipboard) {
            Send "{Text}" . agent
            utils.waitLoading()
            Send "!s"
            utils.waitLoading()
            Send "!o"
            utils.waitLoading()
            Send "{Space}"
            utils.waitLoading()
            Send "!o" 
        }
    }
}
