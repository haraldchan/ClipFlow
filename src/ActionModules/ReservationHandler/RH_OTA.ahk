#Include "../../../../Lib/ClipFlow/DictIndex.ahk"

class BookingEntry {
    ; the initX, initY for USE() should be top-left corner of current booking window
    static USE(infoObj, roomType, comment, pmsGuestNames, initX := 193, initY := 182) {
        MsgBox("Start in seconds...", "Reservation Handler", "T1 4096")

        BookingEntry.profileEntry(pmsGuestNames[1])
        Sleep 1000

        BookingEntry.roomQtyEntry(infoObj["roomQty"])

        BookingEntry.roomTypeEntry(roomType)

        BookingEntry.dateTimeEntry(infoObj["ciDate"], infoObj["coDate"])

        BookingEntry.commentOrderIdEntry(infoObj["orderId"], comment)

        if (!(jsa.every((item) => item = 0, infoObj["bbf"]))) {
            BookingEntry.breakfastEntry(infoObj["bbf"])
        }

        BookingEntry.roomRatesEntry(infoObj["roomRates"])

        MsgBox("Completed.", "Reservation Handler", "T1 4096")
        ; Utils.cleanReload(winGroup)
    }

    ; tested
    static addFromTemplates(agentTemplate) {
        Send "!r"
        sleep 100
        Send "u"
        Sleep 500
        Send Format("{Text}{1}", agentTemplate)
        Sleep 100
        Send "!h"
        Sleep 100
        Send "!t"
        Sleep 100
        Send "!o"
        Sleep 100
        Send "!o"
        Sleep 100
        loop 5 {
            Send "{Esc}"
            Sleep 200
        }
        Sleep 100
    }

    static profileEntry(guestName, initX := 471, initY := 217) {
        trayTip "录入中：Profile"
        Sleep 1000
        MouseMove initX, initY ;471, 217
        Click
        Sleep 3000
        Send "!n"
        Sleep 100
        MouseMove initX - 39, initY + 68 ;432, 285
        Sleep 100
        Click 3
        Sleep 100
        Send Format("{Text}{1}", guestName[1])
        Sleep 100
        MouseMove initX - 72, initY + 95 ;399, 312
        Sleep 100
        Click 3
        Sleep 100
        Send Format("{Text}{1}", guestName[2])
        Sleep 100
        if (guestName.Length = 3) {
            MouseMove initX - 17, initY + 67 ; 454, 284
            Sleep 100
            Click 3
            Sleep 3000
            Send Format("{Text}{1}", guestName[3])
            Sleep 100
            Send "!o"
        }
        Sleep 1500
        Send "!o"
        Sleep 2000
    }

    static roomQtyEntry(roomQty, initX := 294, initY := 441) {
        trayTip "录入中：房间数量"
        ; TODO: fill-in roomQty
        MouseMove initX, initY
        Sleep 100
        Click 3
        Sleep 100
        Send Format("{Text}{1}", roomQty)
        Sleep 100
        Send "{Tab}"
        Sleep 100
        loop 5 {
            Send "{Esc}"
            Sleep 300
        }
        Sleep 100
    }

    static roomTypeEntry(roomType, initX := 472, initY := 465) {
        trayTip "录入中：房型"
        MouseMove 500, 469 ; RTC btn
        Sleep 100
        Click
        Sleep 100
        Send Format("{Text}{1}", roomType)
        Sleep 100
        Send "!o"
        Sleep 100
        loop 3 {
            Send "{Esc}"
            Sleep 400
        }
        
        MouseMove 350, 469 ; Room Type btn
        Sleep 100
        Click
        Sleep 100
        Send Format("{Text}{1}", roomType)
        Sleep 100
        Send "!o"
        Sleep 100
        loop 3 {
            Send "{Esc}"
            Sleep 400
        }

        Sleep 100
    }

    static dateTimeEntry(checkin, checkout, initX := 332, initY := 356) {
        trayTip "录入中：入住/退房日期"
        pmsCiDate := FormatTime(checkin, "MMddyyyy")
        pmsCoDate := FormatTime(checkout, "MMddyyyy")
        Sleep 100
        MouseMove 349, 363
        Sleep 100
        Click 
        Sleep 100
        Send "!c"
        Sleep 100
        Send Format("{Text}{1}", pmsCiDate)
        Sleep 100
        Send "{Tab}"
        Sleep 100
        loop 5 {
            Send "{Esc}"
            Sleep 300
        }

        MouseMove 350, 404
        Sleep 100
        Click 
        Sleep 100
        Send "!c"
        Sleep 100
        Send Format("{Text}{1}", pmsCoDate)
        Sleep 100
        Send "{Enter}"
        Sleep 100
        loop 5 {
            Send "{Esc}"
            Sleep 300
        }
        Sleep 100
    }

    static commentOrderIdEntry(orderId, comment, initX := 622, initY := 596) {
        trayTip "录入中：COMMENT，订单号"
        ; fill-in comment
        Sleep 100
        MouseMove initX, initY ;622, 596
        Sleep 100
        Click "Down"
        MouseMove initX + 518, initY + 9 ;1140, 605
        Sleep 100
        Click "Up"
        Sleep 100
        Send Format("{Text}{1}", comment)
        Sleep 100
        ; fill-in orderId
        Sleep 100
        MouseMove initX + 217, initY - 41 ;839, 555
        Sleep 100
        Click "Down"
        MouseMove initX + 485, initY - 33 ;1107, 563
        Sleep 100
        Click "Up"
        Sleep 100
        Send Format("{Text}{1}", orderId)
        Sleep 100
        loop 5 {
            Send "{Esc}"
            Sleep 200
        }
        Sleep 100
    }

    static roomRatesEntry(roomRates, initX := 372, initY := 524) {
        trayTip "录入中：房价"
        MouseMove initX, initY ;372, 504
        Sleep 100
        Click
        Sleep 100
        loop 5 {
            Send "{Esc}"
            Sleep 100
        }
        Sleep 100
        Send "!d"
        Sleep 1000
        loop roomRates.Length {
            Send "!e"
            Sleep 100
            MouseMove 503, 422
            Sleep 100
            Click 3
            Sleep 100
            Send roomRates[A_Index]
            Sleep 100
            Send "!o"
            Send "{Down}"
            Sleep 100
        }
        Sleep 100
        MouseMove initX + 356, initY + 44 ;728, 548
        Sleep 100
        Send "!o"
        Sleep 500
        Send "{Esc}"
        Sleep 100
    }

    static breakfastEntry(bbf, initX := 352, initY := 548) {
        trayTip "录入中：早餐"
        ;entry bbf package
        Sleep 100
        MouseMove initX, initY
        Sleep 100
        Click
        Sleep 2000
        Send "!n"
        Sleep 100
        Send "{Text}BFNP"
        Sleep 100
        Send "!o"
        Sleep 1000
        Send "!o"
        Sleep 100
        Send "{Esc}"
        Sleep 500
        ; change "Adults"
        MouseMove initX - 67, initY - 124 ; 285, 424
        Sleep 100
        Click 3
        Send Format("{Text}{1}", bbf[1])
        ; Send "1"
        Sleep 100
        loop 5 {
            Send "{Esc}"
            Sleep 100
        }
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

getPmsRoomType(OtaRoomType, roomTypeMap) {
    roomType := ""
    for k, v in roomTypeMap {
        if (OtaRoomType = k) {
            roomType := v
        }
    }
    return roomType
}

multiBookingNotifier(roomQty, popupTitle) {
    notifierOC := Format("
    (
        订单数量：{1}, 已完成{2}个。
        请先从对应 Agent booking Add-On预订。

        确定(Enter)：     开始修改预订
        取消(Esc)：       退出修改
    )", roomQty, A_Index - 1)
    notifierYNC := Format("
    (
        订单数量：{1}, 已完成{2}个。
        请先打开需要修改的 Fedex 预订。

        是(Yes)：         开始修改预订
        否(No):           跳过此修改    
        取消(Cancel):     退出修改
    )", roomQty, A_Index - 1)
    
    options := roomQty >= 2 ? "YesNoCancel" : "OKCancel"
    notifier := roomQty >= 2 ? notifierYNC : notifierOC
    result := MsgBox(notifier, popupTitle, options . " 4096")
    
    return result
}

; Kingsley WIP
RH_Kingsley(infoObj, addFromConf := 0) {
    ; template booking name
    thisTemplate := "template-kingsley"
    ; convert roomType
    roomTypeRef := Map(
        "标准大床房", "SKC",
        "标准双床房", "STC",
        "豪华城景大床房", "DKC",
        "豪华城景双床房", "DTC",
        "豪华江景大床房", "DKR",
        "豪华江景双床房", "DTR",
        "行政豪华城景大床房", "CKC",
        "行政豪华城景双床房", "CTC",
        "行政豪华江景大床房", "CKR",
        "行政豪华江景双床房", "CTR"
        "行政尊贵套房", "CSK"
    )
    roomType := getPmsRoomType(infoObj["roomType"], roomTypeRef)
    ; define breakfast comment
    breakfastType := (SubStr(roomType, 1, 1) = "C") ? "CBF" : "BBF"
    breakfastQty := infoObj["bbf"][1]
    comment := (breakfastQty = 0)
        ? "RM TO TA"
        : Format("RM INCL {1}{2} TO TA", breakfastQty, breakfastType)

    ; reformat guest names
    pmsGuestNames := []
    loop infoObj["guestNames"].Length {
        curGuestName := infoObj["guestNames"][A_Index]
        if (RegExMatch(curGuestName, "^[a-zA-Z/]+$") > 0) {
            ; if only includes English alphabet, push [lastName, firstName]
            pmsGuestNames.Push(StrSplit(curGuestName, "/"))
        } else {
            pmsGuestNames.Push([
                getFullnamePinyin(curGuestName)[1], ; lastName pinyin
                getFullnamePinyin(curGuestName)[2], ; firstName pinyin
                curGuestName, ; hanzi-name
            ])
        }
    }

    ; Main booking modification
    BookingEntry.USE(
        thisTemplate,
        infoObj,
        roomType,
        comment,
        pmsGuestNames
    )
}

; Fliggy WIP
RH_Fliggy(infoObj, addFromConf := 0) {
    thisTemplate := "template-fliggy"
    roomTypeRef := Map(
        "城景标准中床房", "SKC",
        "标准大床房", "SKC",
        "城景标准双床房", "STC",
        "标准双床房", "STC",
        "豪华城景大床房", "DKC",
        "豪华城景双床房", "DTC",
        "豪华江景大床房", "DKR",
        "豪华江景双床房", "DTR",
        "城景行政豪华大床房", "CKC",
        "城景行政豪华大床房", "CKR",
        "行政尊贵套房", "CSK",
    )
    roomType := getPmsRoomType(infoObj["roomType"], roomTypeRef)
    breakfastType := (SubStr(roomType, 1, 1) = "C") ? "CBF" : "BBF"
    breakfastQty := infoObj["bbf"][1]

    commentBreakfast := (breakfastQty = 0)
        ? ""
        : Format(" INCL {1}{2} ", breakfastQty, breakfastType)
    commentBenefits := infoObj["remarks"] = ""
        ? ""
        : Format(",{1}", infoObj["remarks"])
    comment := infoObj["payment"] = "信用住"
        ? Format("All{1}{2} TO 信用住。{3}", commentBreakfast, commentBenefits, infoObj["invoiceMemo"])
        : Format("RM {1}{2} TO TA。{3}", commentBreakfast, commentBenefits, infoObj["invoiceMemo"])

    pmsGuestNames := []
    loop infoObj["guestNames"].Length {
        curGuestName := infoObj["guestNames"][A_Index]
        if (RegExMatch(curGuestName, "^[a-zA-Z]+$") > 0) {
            ; if only includes English alphabet, push [lastName, firstName]
            pmsGuestNames.Push(StrSplit(curGuestName, " "))
        } else {
            pmsGuestNames.Push([
                getFullnamePinyin(curGuestName)[1], ; lastName pinyin
                getFullnamePinyin(curGuestName)[2], ; firstName pinyin
                curGuestName, ; hanzi-name
            ])
        }
    }

    ; Main booking modification
    BookingEntry.USE(
        infoObj,
        roomType,
        comment,
        pmsGuestNames
    )
}

; Agoda WIP
RH_Agoda(infoObj, addFromConf := 0) {
    roomTypeRef := Map(
        "Standard Room - Queen bed", "SKC",
        "Standard Room - Twin Bed", "STC",
        "Deluxe City View with King Bed", "DKC",
        "Deluxe City View Twin Bed", "DTC",
        "Deluxe River View King Bed", "DKR"
        "Deluxe River View Twin Bed", "DTR",
        "Club Deluxe City View", "CKC",
        "Club Deluxe River View Room", "CKR",
        "Club Premier Suite", "CPK",
    )

    roomType := getPmsRoomType(infoObj["roomType"], roomTypeRef)

    breakfastType := (SubStr(roomType, 1, 1) = "C") ? "CBF" : "BBF"
    comment := Format("ROOM INCL {1}{2} PAY BY AGODA", infoObj["bbf"][1], breakfastType)
}

RH_Webbeds(infoObj) {
    roomTypeRef := Map(
        "CITY VIEW DELUXE KING ROOM", "DKC",
        "CITY VIEW DELUXE TWIN ROOM", "DTC",
        "RIVER VIEW DELUXE KING ROOM", "DKR",
        "RIVER VIEW DELUXE TWIN ROOM", "DTR",
    )

    roomType := getPmsRoomType(infoObj["roomType"], roomTypeRef)
    breakfastType := (SubStr(roomType, 1, 1) = "C") ? "CBF" : "BBF"
    orderIdList := infoObj["orderId"]

    loop infoObj["roomQty"] {
        infoObj["orderId"] := orderIdList[A_Index]
        
        bbf := infoObj["bbf"][1] = 0
            ? "" : infoObj["bbf"][1] = 1
            ? "INCL 1" . breakfastType : "INCL 2" . breakfastType
        comment := Format("RM {1}PAY BY GIVEN CREDIT CARD: {2} EXP:{3}",
            bbf,
            infoObj["creditCardNumbers"][A_Index],
            infoObj["creditCardExp"][A_Index])
        guestNames := [ StrSplit(infoObj["guestNames"][1], " ") ]

        popup := multiBookingNotifier(infoObj["roomQty"], "Reservation Handler")

        if (popup = "Cancel") {
            utils.cleanReload(winGroup)
        } else if (popup = "No") {
            continue
        } else if (A_Index = 1 && popup = "Yes" || popup = "OK") {
            BookingEntry.USE(infoObj, roomType, comment, guestNames)
        } else {
            BookingEntry.commentOrderIdEntry(infoObj["orderId"], comment)
        }
        if (A_Index = infoObj["roomQty"]) {
            MsgBox("已完成所有录入。", "Reservation Handler", "T1 4096")
        }
    }
}