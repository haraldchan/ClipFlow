class FedexBookingEntry {
    static USE(infoObj, curIndex, initX := 194, initY := 183) {
        pmsCiDate := (StrSplit(infoObj["ETA"], ":"))[1] < 10
            ? DateAdd(infoObj["ciDate"], -1, "days")
            : infoObj["ciDate"]
        pmsCoDate := infoObj["coDate"]
        pmsNts := DateDiff(pmsCoDate, pmsCiDate, "days")

        this.profileEntry(infoObj["crewNames"])
        Sleep 500

        ; only enter neccessary field when resvType is CHANGE or first loop of ADD
        if (infoObj["resvType"] = "ADD" && curIndex = 1 || infoObj["resvType"] = "CHANGE") {
            if (infoObj["resvType"] = "ADD") {
                this.roomQtyEntry(infoObj["crewNames"].Length)
            }
            Sleep 500

            this.dateTimeEntry(infoObj["ciDate"], infoObj["coDate"], infoObj["ETA"], infoObj["ETD"])
            Sleep 500

            this.moreFieldsEntry(infoObj)
            Sleep 500

            this.commentEntry(infoObj)
            Sleep 500

            if (infoObj["daysActual"] < pmsNts) {
                this.dailyDetailsEntry(infoObj["daysActual"])
            }
            Sleep 500

            this.crsNumEntry(infoObj["tracking"])
            Sleep 500
        }

        ; post Alert reminder when room charge needs to be post manually
        if (infoObj["daysActual"] > pmsNts) {
            this.postRoomChargeAlertEntry(pmsNts, infoObj["daysActual"])
        }
    }

    static profileEntry(crewNames, initX := 471, initY := 217) {
        crewName := StrSplit(crewNames[A_Index], " ")

        MouseMove initX, initY ; 471, 217
        Click
        Sleep 3000
        MouseMove initX - 91, initY + 338 ; 380, 555
        Sleep 10
        Click
        Sleep 10
        Send Format("{Text}{1}", crewName[2])
        Sleep 10
        Send "{Tab}"
        Sleep 10
        Send Format("{Text}{1}", crewName[1])
        Sleep 10
        Send "{Tab}"
        Sleep 500 ; delay must be >= 500ms

        ; check profile existence
        CoordMode "Pixel", "Screen"
        if (PixelGetColor(initX + 109, initY + 288) != "0x0000FF") { ; profile is found 580, 505
            Send "{Enter}"
            Sleep 100
        } else { ; profile not found, create a new one
            Send "{Enter}"
            Sleep 100
            Send "!n"
            Sleep 100
            Send "{Esc}"
            Sleep 100
            MouseMove initX - 39, initY + 68 ; 432, 285
            Sleep 10
            Click 3
            Sleep 10
            Send Format("{Text}{1}", crewName[2])
            MouseMove initX - 72, initY + 95 ; 399, 312
            Sleep 10
            Click 3
            Sleep 10
            Send Format("{Text}{1}", crewName[1])
            Sleep 10
        }
        Send "!o"
        Sleep 3000
    }

    static roomQtyEntry(roomQty, initX := 294, initY := 441) {
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
            Sleep 100
        }
        Sleep 100
    }

    static dateTimeEntry(checkin, checkout, ETA, ETD, initX := 323, initY := 506) {
        pmsCiDate := (StrSplit(ETA, ":")[1]) < 10
            ? FormatTime(DateAdd(checkin, -1, "days"), "MMddyyyy")
            : FormatTime(checkin, "MMddyyyy")
        pmsCoDate := FormatTime(checkout, "MMddyyyy")
        MouseMove initX + 9, initY - 150 ; 332, 356
        Sleep 100
        ; fill-in checkin/checkout
        MouseMove initX + 9, initY - 150 ; 332, 356
        Sleep 100
        Click 2 
        Sleep 100
        Send "!c"
        Sleep 100
        Send Format("{Text}{1}", pmsCiDate)
        Sleep 100
        MouseMove initX + 2, initY - 108 ; 325, 398
        Sleep 100
        Click
        Sleep 100
        MouseMove initX + 338, initY + 37 ; 661, 543
        Sleep 100
        Click
        MouseMove initX + 313, initY + 37 ; 636, 543
        Sleep 100
        Click
        MouseMove initX + 312, initY + 37 ; 635, 543
        Sleep 100
        Click
        Sleep 100
        Click
        Sleep 100
        MouseMove initX + 12, initY - 101 ; 335, 405
        Sleep 100
        Click 2 
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
        ; fill in ETA & ETD
        MouseMove initX - 29, initY + 91 ; 294, 597
        Sleep 100
        MouseMove initX - 3, initY + 91 ; 320, 597
        Sleep 100
        Click "Down"
        MouseMove initX - 123, initY + 91 ; 200, 597
        Sleep 100
        Click "Up"
        Sleep 100
        Send Format("{Text}{1}", ETA)
        Sleep 100
        MouseMove initX + 176, initY + 91 ; 499, 597
        Sleep 100
        Click "Down"
        MouseMove initX + 7, initY + 88 ; 330, 594
        Sleep 100
        Click "Up"
        Sleep 100
        Send Format("{Text}{1}", ETD)
        Sleep 100
    }

    static commentEntry(infoObj, initX := 622, initY := 589) {
        comment := ""

        ; select current comment
        MouseMove initX, initY ; 622, 596
        Sleep 100
        Click "Down"
        MouseMove initX + 518, initY + 36 ; 1140, 605
        Sleep 100
        Click "Up"
        Sleep 100
        Send "^x"
        Sleep 100

        ; set new comment
        if (infoObj["resvType"] = "ADD") {
            comment := Format("RM INCL 1BBF TO CO,Hours@Hotel: {1}={2}day(s), ActualStay: {3}-{4}", infoObj["stayHours"], infoObj["daysActual"], infoObj["ciDate"], infoObj["coDate"])
        } else {
            prevComment := A_Clipboard
            comment := Format("Changed to {1}={2}day(s), New Stay:{3}-{4} // Before Update:{5}", infoObj["stayHours"], infoObj["daysActual"], infoObj["ciDate"], infoObj["coDate"], prevComment)
        }

        ; fill-in comment

        ; probably no need to click again (might cause unexpected double click).
        ; Sleep 100
        ; MouseMove initX, initY ; 622, 596
        ; Sleep 500
        ; Click

        Sleep 100
        Send Format("{Text}{1}", comment)
        Sleep 100

        ; fill-in new flight and trip
        MouseMove initX + 307, initY - 35 ; 929, 554
        Sleep 100
        Click 3
        Sleep 100
        Send Format("{Text}{1}  {2}", infoObj["flightIn"], infoObj["tripNum"])
        Sleep 100
    }

    static moreFieldsEntry(infoObj, initX := 236, initY := 333) {
        schdCiDate := FormatTime(infoObj["ciDate"], "MMddyyyy")
        schdCoDate := FormatTime(infoObj["coDate"], "MMddyyyy")

        MouseMove initX, initY ; 236, 333
        Sleep 100
        Click
        Sleep 100
        MouseMove 680, 460
        Sleep 100
        Click 2
        Sleep 100
        Send Format("{Text}{1}", infoObj["flightIn"])
        Sleep 100
        loop 2 {
            Send "{Tab}"
            Sleep 100
        }
        Send Format("{Text}{1}", schdCiDate)
        Sleep 100
        Send "{Tab}"
        Sleep 100
        Send Format("{Text}{1}", infoObj["ETA"])
        Sleep 100
        MouseMove 917, 465
        Sleep 100
        Click 2
        Sleep 100
        Send Format("{Text}{1}", infoObj["flightOut"])
        Sleep 100
        loop 2 {
            Send "{Tab}"
            Sleep 100
        }
        Sleep 100
        Send Format("{Text}{1}", schdCoDate)
        Sleep 100
        Send "{Tab}"
        Sleep 100
        Send Format("{Text}{1}", infoObj["ETD"])
        Sleep 100
        MouseMove initX + 605, initY + 347 ; 841, 680
        Sleep 100
        Click
        Sleep 100
    }

    static dailyDetailsEntry(daysActual, initX := 372, initY := 524) {
        MouseMove initX, initY ; 372, 524
        Sleep 100
        Click
        Sleep 100
        Send "!d"
        Sleep 1500
        loop daysActual {
            Send "{Down}"
            Sleep 200
        }
        Send "!e"
        Sleep 100
        loop 4 {
            Send "{Tab}"
            Sleep 200
        }
        Send "{Text}NRR"
        Sleep 100
        Send "!o"
        loop 3 {
            Send "{Escape}"
            Sleep 200
        }
        Sleep 300
        Send "!o"
        Sleep 100
        loop 5 {
            Send "{Escape}"
            Sleep 200
        }
        Sleep 100
    }
    ; WIP
    static splitParty(crewNames, initX := 456, initY := 482) {
        Send "!t"
        Sleep 100
        MouseMove initX, initY
        Sleep 100
        Send Click
        Sleep 100
        Send "!s" ; !s: Split; !a: Split All
        Sleep 100
        Send "!r"
        Sleep 1000
    }

    static rateCodeEntry(initX := 326, initY := 507) {
        MouseMove initX, initY
        Sleep 100
        Click "Down"
        Sleep 100
        MouseMove initX - 71, initY
        Sleep 100
        Click "Up"
        Sleep 100
        Send "{Text}FEDEXN"
        Sleep 100
        Send "{Tab}"
        Sleep 100
        loop 3 {
            Send "{Esc}"
            Sleep 100
        }
    }

    static postRoomChargeAlertEntry(pmsNts, daysActual, initX := 759, initY := 266) {
        Send "!t"
        MouseMove initX, initY ; 759, 266
        Sleep 100
        Click
        Send "!n"
        Sleep 100
        Send "{Text}OTH"
        MouseMove initX - 242, initY + 133 ; 517, 399
        Sleep 100
        Click
        MouseMove initX - 280, initY + 169 ; 479, 435
        Sleep 100
        Click
        MouseMove initX - 70, initY + 211 ; 689, 477
        Sleep 100
        Click "Down"
        MouseMove initX - 62, initY + 211 ; 697, 477
        Sleep 100
        Click "Up"
        Sleep 100
        Send Format("{Text}实际需收取 {1} 晚房费。退房请补入 {2} 晚房费。", daysActual, daysActual - pmsNts)
        Sleep 150
        Send "!o"
        Sleep 400
        Send "!c"
        Sleep 200
        Send "!c"
        Sleep 200
    }

    static crsNumEntry(tracking, initX := 739, initY := 505){
        MouseMove initX, initY
        Sleep 100
        Click
        Sleep 100
        Send "!n"
        Sleep 100
        MouseMove initX - 29, initY - 99
        Sleep 100
        Click
        Sleep 100
        Send "{Down}"
        Sleep 100
        Send "!o"
        Sleep 100
        Send Format("{Text}{1}", tracking)
        Sleep 100
        Send "!o"
        Sleep 100
        Send "!c"
        Sleep 100
    }   
}

RH_Fedex(infoObj) {
    roomQty := infoObj["crewNames"].Length

    ; starter
    if (infoObj["resvType"] = "CHANGE") {
        changeModification(infoObj)
    } else {
        addModification(infoObj)
    }

    addModification(infoObj) {
        loop roomQty {
            notifierOC := Format("
                (
                    新增订单数量：{1}, 已完成{2}个。
                    请先新增一个booking并打开，按下
                    确定后开始修改。

                    确定(Enter)：     开始录入新增
                    取消(Esc)：       退出新增
                )", roomQty, A_Index - 1)
            notifierYNC := Format("
                (
                    新增订单数量：{1}, 已完成{2}个。
                    请先打开需要录入新增信息的预订。

                    是(Yes)：         开始录入新增
                    否(No):           跳过第一个修改    
                    取消(Cancel):     退出新增
                )", roomQty, A_Index - 1)

            options := roomQty = 2 ? "YesNoCancel" : "OKCancel"
            notifier := roomQty = 2 ? notifierYNC : notifierOC
            if (A_Index = 2) {
                notifier := notifierOC
                options := "OKCancel"
            }
            changePopup := MsgBox(notifier, "RH-FedEx - ADD", options . " 4096")
            if (changePopup = "Cancel") {
                utils.cleanReload(winGroup)
            } else if (changePopup = "No") {
                continue
            } else {
                FedexBookingEntry.USE(infoObj, A_Index)
            }
            ; split and open a booking, modified again(second loop)
            if (A_Index = 1 && roomQty > 1) {
                ; change msgbox to save actions later!
                MsgBox("已完成第一个新增`n`n请先保存，并打开 Party → Split → Resv 进入下一个预订继续修改", "RH-FedEx - ADD", "4096")
                ; FedexBookingEntry.splitParty()
            }
            ; leave close and save manually ???
            if (A_Index = roomQty) {
                MsgBox("已完成所有新增。", "RH-FedEx - ADD", "T1 4096")
            }
        }
        utils.cleanReload(winGroup)
    }

    changeModification(infoObj) {
        loop roomQty {
            notifierOC := Format("
                (
                    待修改订单数量：{1}, 已完成{2}个。
                    请先打开需要修改的 Fedex 预订。

                    确定(Enter)：     开始修改预订
                    取消(Esc)：       退出修改
                )", roomQty, A_Index - 1)
            notifierYNC := Format("
                (
                    待修改订单数量：{1}, 已完成{2}个。
                    请先打开需要修改的 Fedex 预订。

                    是(Yes)：         开始修改预订
                    否(No):           跳过第一个修改    
                    取消(Cancel):     退出修改
                )", roomQty, A_Index - 1)

            options := roomQty = 2 ? "YesNoCancel" : "OKCancel"
            notifier := roomQty = 2 ? notifierYNC : notifierOC
            if (A_Index = 2) {
                notifier := notifierOC
                options := "OKCancel"
            }
            changePopup := MsgBox(notifier, "RH-FedEx - CHANGE", options . " 4096")
            if (changePopup = "Cancel") {
                utils.cleanReload(winGroup)
            } else if (changePopup = "No") {
                continue
            } else if (changePopup = "Yes") {
                FedexBookingEntry.USE(infoObj, A_Index)
            } else {
                FedexBookingEntry.USE(infoObj, A_Index)
            }
            ; leave close and save manually ???
            if (A_Index = roomQty) {
                MsgBox("已完成所有修改。", "RH-FedEx - CHANGE", "T1 4096")
            }
        }
        utils.cleanReload(winGroup)
    }
}