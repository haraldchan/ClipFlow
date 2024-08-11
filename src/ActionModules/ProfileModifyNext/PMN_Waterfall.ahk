class PMN_Waterfall {
    static cascade(rooms, selectedGuests) {
        WinMaximize "ahk_class SunAwtFrame"
        WinSetAlwaysOnTop true, "ahk_class SunAwtFrame"
        BlockInput true

        curRoom := signal(0)

        for room in rooms {
            curRoom.set(room)

            for guest in selectedGuests {
                remaining := selectedGuests.filter(g => g["roomNum"] = curRoom.value).Length
                isLastOne := remaining = 1 ? true : false
                
                if (guest["roomNum"] = curRoom.value) {
                    this.search(room, isLastOne)
                    utils.waitLoading()
                    this.modify(guest, isLastOne)
                    guest["roomNum"] := ""
                }
            }
        }

        WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"
        BlockInput false
        Sleep 1000
        MsgBox("已完成全部选中 Profile 录入。", "Waterfall cascaded", "4096 T1")
    }

    static search(roomNum, isLastOne) {
        formattedRoom := StrLen(roomNum) = 3 ? "0" . roomNum : roomNum

        MouseMove 329, 196 ; room number field
        Click 3
        utils.waitLoading()
        
        Send formattedRoom
        utils.waitLoading()

        if (isLastOne = false) {
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
        }

        Send "!h" ; alt+h => search
        utils.waitLoading()

        if (isLastOne = true) {
            Click 838, 378, "Right" 
            utils.waitLoading()
            Send "{Down}"
            utils.waitLoading()
            Send "{Enter}"
            utils.waitLoading()
        }
    }

    static modify(guest, isLastOne) {        
        Send "!p" ; open profile
        utils.waitLoading()
        sleep 1000

        Send "!n"
        utils.waitLoading()
        
        PMN_FillIn.fill(guest)
        Sleep 1000
        
        Send "!o" ; ok
        utils.waitLoading()
        sleep 1000

        if (isLastOne = false) {
            Send "!r" ; clear
        }
    }
}