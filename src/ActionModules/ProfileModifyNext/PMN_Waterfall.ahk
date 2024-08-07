class PMN_Waterfall {
    static cascade(rooms, selectedGuests) {
        WinMaximize "ahk_class SunAwtFrame"
        WinSetAlwaysOnTop true, "ahk_class SunAwtFrame"
        BlockInput true

        for room in rooms {

            for guest in selectedGuests {
                remaining := selectedGuests.filter(g => g["roomNum"] = room).Length
                isLastOne := remaining = 1 ? true : false
                
                if (guest["roomNum"] = room) {
                    this.search(room, isLastOne)
                    utils.waitLoading()
                    this.modify(guest)
                }

                guest["roomNum"] := ""
            }
        }

        WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"
        BlockInput false
        Sleep 1000
        MsgBox("Modify 已完成。", "Waterfall")
    }

    static search(roomNum, isLastOne) {
        MouseMove 329, 196 ; room number field
        Click 3
        utils.waitLoading()
        
        Send roomNum
        utils.waitLoading()

        ; solution 1: filter by "1"
        ; Send "{Tab}" ; last name field
        ; utils.waitLoading()
        ; Send Format("{Text}{1}", isLastOne ? "" : "1") ; send "1" if not last one
        ; utils.waitLoading()

        ; solution 2: filter by NRR
        Send "!a"
        utils.waitLoading()
        loop 4 {
            Send "{Tab}"
            utils.waitLoading()
        }
        Send Format("{Text}{1}", isLastOne ? "NRR" : "TGDA")
        utils.waitLoading()

        Send "!h" ; alt+h => search
        utils.waitLoading()

        if (isLastOne = true) {
            MouseMove 1, 1 ; TODO: this should be the adult sorting field
            Click
            utils.waitLoading()
            ; TODO: see if the main profile is on-top and focused
        }
    }

    static modify(guest) {        
        Send "!p" ; open profile
        utils.waitLoading()
        sleep 1000
        
        PMN_FillIn.fill(guest)
        Sleep 1000
        Send "!o" ; ok
        
        utils.waitLoading()
        sleep 1000
        Send "!r" ; clear
    }
}