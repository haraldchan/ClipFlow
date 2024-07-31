#Include "../ProfileModifyNext/PMN_FillIn.ahk"
class PMNG_Execute {
    static startModify(groupName, inhRooms, groupGuests) {
        for room in inhRooms {
            curIndex := 1

            for guest in groupGuests {
                if (guest["roomNum"] = room) {
                    this.search(room, curIndex)
                    utils.waitLoading()
                    this.modify()
                    curIndex++
                    
                    if (curIndex > 2) {
                        break
                    }
                }
            }
        }

        MsgBox("Group Modify 已完成。")
    }

    static search(roomNum, roomLoopIndex) {
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
        
        Send "!p" ; profile
        ; wait for profile win
        loop 10 {
            Sleep 1000
            if (anchorIsVisible) {
                break
            }
        }
        
        PMN_FillIn.fill(guest)
        Sleep 500
        Send "!o" ; ok
        
        ; wait for profile win to close
        loop 10 {
            Sleep 1000
            if(!anchorIsVisible) {
                break
            }
        }

        Send "!r" ; clear
    }
}