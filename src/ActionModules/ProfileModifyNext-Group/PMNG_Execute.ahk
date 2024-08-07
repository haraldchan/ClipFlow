#Include "../ProfileModifyNext/PMN_FillIn.ahk"
class PMNG_Execute {
    static startModify(inhRooms, groupGuests) {
        uInhRomms := inhRooms.unique()

        WinMaximize "ahk_class SunAwtFrame"
        WinSetAlwaysOnTop true, "ahk_class SunAwtFrame"
        BlockInput true

        for room in uInhRomms {
            curIndex := 1

            for guest in groupGuests {
                if (guest["roomNum"] = room) {
                    this.search(room, curIndex)
                    utils.waitLoading()
                    this.modify(guest)

                    curIndex++
                    if (curIndex > 2) {
                        break
                    }
                }
            }
        }

        WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"
        BlockInput false
        Sleep 1000
        MsgBox("Group Modify 已完成。")
    }

    static search(roomNum, roomLoopIndex) {

        MouseMove 329, 196
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
        Send Format("{Text}{1}", roomLoopIndex = 1 ? "TGDA" : "NRR")
        utils.waitLoading()
        Send "!h" ; alt+h => search
        utils.waitLoading()
    }

    static modify(guest := 0) {
        CoordMode "Pixel", "Screen"
        anchorImage := A_ScriptDir . "\src\Assets\AltNameAnchor.PNG"
        anchorIsVisible := ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenWidth, anchorImage)
        
        Send "!p" ; 
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