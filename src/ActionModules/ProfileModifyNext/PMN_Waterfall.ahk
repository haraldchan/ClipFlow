class PMN_Waterfall {
    static cascade(rooms, selectedGuests, isOverwrite) {
        WinMaximize "ahk_class SunAwtFrame"
        WinSetAlwaysOnTop true, "ahk_class SunAwtFrame"
        BlockInput true

        curRoom := signal(0)
        index := 1

        for room in rooms {
            curRoom.set(room)

            for guest in selectedGuests {
                remaining := selectedGuests.filter(g => g["roomNum"] = curRoom.value).Length

                if (guest["roomNum"] = curRoom.value) {
                    this.search(room, index)
                    utils.waitLoading()
                    this.modify(guest, isOverwrite)
                    if (!PMN_FillIn.isRunning) {
                        return
                    }

                    guest["roomNum"] := ""
                    index := (remaining = 1) ? 1 : index + 1

                    if (remaining = 1) {
                        break
                    }
                }
            }
        }

        WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"
        BlockInput false
        MsgBox("已完成全部选中 Profile 录入。", "Waterfall cascaded", "4096 T1")
    }

    static search(roomNum, index) {
        formattedRoom := StrLen(roomNum) = 3 ? "0" . roomNum : roomNum

        MouseMove 329, 196 ; room number field
        Click 3
        utils.waitLoading()
        
        Send formattedRoom
        utils.waitLoading()

        Send "!h" ; alt+h => search
        utils.waitLoading()

        ; sort by Prs.
        Click 838, 378, "Right" 
        utils.waitLoading()
        Send "{Down}"
        utils.waitLoading()
        Send "{Enter}"
        utils.waitLoading() 

        ; choose resv
        loop (index - 1) {
            Send "{Down}"
            utils.waitLoading()
        }
    }

    static modify(guest, isOverwrite) { 
        Send "!p" ; open profile
        utils.waitLoading()
        
        PMN_FillIn.fill(guest, isOverwrite)
        utils.waitLoading()
        Sleep 1000

        Send "!o" ; ok
        utils.waitLoading()
        sleep 1000
    }
}