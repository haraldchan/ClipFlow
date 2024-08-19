class PMN_Waterfall {
    static cascade(rooms, selectedGuests) {
        WinMaximize "ahk_class SunAwtFrame"
        WinSetAlwaysOnTop true, "ahk_class SunAwtFrame"
        BlockInput "SendAndMouse"

        curRoom := signal(0)
        index := 1

        for room in rooms {
            curRoom.set(room)

            for guest in selectedGuests {
                remaining := selectedGuests.filter(g => g["roomNum"] = curRoom.value).Length
                
                if (guest["roomNum"] = curRoom.value) {
                    this.search(room, index)
                    utils.waitLoading()
                    this.modify(guest)
                    guest["roomNum"] := ""
                    index := (remaining = 1) ? 1 : index + 1
                }

                if (remaining = 1) {
                    break
                }
            }
        }

        WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"
        BlockInput false
        Sleep 1000
        MsgBox("已完成全部选中 Profile 录入。", "Waterfall cascaded", "4096 T1")
    }

    static search(roomNum, index) {
        formattedRoom := StrLen(roomNum) = 3 ? "0" . roomNum : roomNum

        MouseMove 329, 196 ; room number field
        Click 3
        utils.waitLoading()
        
        Send formattedRoom
        utils.waitLoading()

        if (index = 1) {
            Send "!h" ; alt+h => search
            utils.waitLoading()

            Click 838, 378, "Right" 
            utils.waitLoading()
            Send "{Down}"
            utils.waitLoading()
            Send "{Enter}"
            utils.waitLoading()
        } else {
            Send "{Tab}" ; last name field
            utils.waitLoading()
            Send Format("{Text}{1}", "1") 
            utils.waitLoading()

            Send "!a"
            utils.waitLoading()
            loop 4 {
                Send "{Tab}"
                utils.waitLoading()
            }
            Send Format("{Text}{1}", "NRR")
            utils.waitLoading()

            Send "!h" ; alt+h => search
            utils.waitLoading()
        }
    }

    static modify(guest) { 
        CoordMode "Pixel", "Screen"
        CoordMode "Mouse", "Screen"
        AnchorImage := A_ScriptDir . "\src\Assets\AltNameAnchor.PNG"
        FOUND := "0x000080"
        NOT_FOUND := "0x008080"

        Send "!p" ; open profile
        utils.waitLoading()
        
        loop {
            Sleep 100
            if (A_Index > 30) {
                MsgBox("界面定位失败", popupTitle, "T2 4096")
                utils.cleanReload(winGroup)
            }

            if (ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenWidth, AnchorImage)) {
                x := Number(FoundX) + 350
                y := Number(FoundY) + 80
                break
            } else {
                continue
            }
        }

        Send "!h" ; search
        utils.waitLoading()
        loop 12 {
            Send "{Tab}"
            Sleep 10
        }
        Send Format("{Text}{1}", guest["idNum"])
        utils.waitLoading()
        Send "!h" ; search 
        utils.waitLoading()
        Sleep 500

        res := PixelGetColor(x, y)
        utils.waitLoading()
        if (res = FOUND) {
            Send "!o"
        } else {
            Send "!c"
            utils.waitLoading()
            Send "!n"
            utils.waitLoading()
        
            PMN_FillIn.fill(guest)
            Sleep 1000
        }

        Send "!o" ; ok
        utils.waitLoading()
        sleep 1000
    }
}