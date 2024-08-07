#Include "../ProfileModifyNext/PMN_FillIn.ahk"
class PMNG_Execute {
    static startModify(inhRooms, groupGuests) {
        uInhRomms := inhRooms.unique()

        WinMaximize "ahk_class SunAwtFrame"
        WinSetAlwaysOnTop true, "ahk_class SunAwtFrame"
        BlockInput true

        for room in uInhRomms {

            for guest in groupGuests {
                remaining := groupGuests.filter(g => g["roomNum"] = room).Length
                isLastOne := remaining = 1 ? true : false

                if (A_Index > inhRooms.filter(r => r = room).Length) {
                    this.search(room, false)
                    this.makeShare()
                    Send "!r" ; clear
                }

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
        MsgBox("Group Modify 已完成。")
    }

    static search(roomNum, isLastOne) {
        MouseMove 329, 196 ; room number field
        click 3
        utils.waitLoading()

        Send roomNum
        utils.waitLoading()
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

    static makeShare(initX := 949, initY := 599) {
        Send "!t"
        utils.waitLoading()
        Send "!s"
        utils.waitLoading()
        Send "!m"
        utils.waitLoading()
        Send "{Esc}"
        utils.waitLoading()
        Send "{Text}1"
        utils.waitLoading()
        loop 4 {
            Send "{Tab}"
            utils.waitLoading()
        }
        Send "{Text}0"
        utils.waitLoading()
        Send "{Tab}"
        utils.waitLoading()
        Send "{Tab}"
        utils.waitLoading()
        Send "{Text}6"
        utils.waitLoading()
        Send "!o"
        utils.waitLoading()
        Send "!r"
        utils.waitLoading()
        MouseMove initX, initY ; 949, 599
        utils.waitLoading()
        Click
        utils.waitLoading()
        Send "!d"
        MouseMove initX - 338, initY - 53 ; 611, 546
        utils.waitLoading()
        Click
        utils.waitLoading()
        Send "!c"
        MouseMove initX - 625, initY - 92 ; 324, 507
        utils.waitLoading()
        Click "Down"
        MouseMove initX - 737, initY - 79 ; 212, 520
        utils.waitLoading()
        Click "Up"
        utils.waitLoading()
        Send "{Text}NRR"
        utils.waitLoading()
        Send "!o"
        utils.waitLoading()
        loop 4 {
            Send "{Esc}"
            utils.waitLoading()
        }
        utils.waitLoading()
        Send "!i"
        utils.waitLoading()
        loop 5 {
            Send "{Esc}"
            utils.waitLoading()
        }
        utils.waitLoading()
        Send "{Space}"
        utils.waitLoading()
        Send "!o"
        utils.waitLoading()
        Send "!c"
        utils.waitLoading()
    }
}