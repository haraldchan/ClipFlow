#Include "../ProfileModifyNext/PMN_FillIn.ahk"
class PMNG_Execute {
    static startModify(groupName, inhRooms, groupGuests) {
        for room in inhRooms {
            curIndex := 1

            for guest in groupGuests {
                if (guest["roomNum"] = room) {
                    this.search(room, curIndex = 1 ? groupName : 1)
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

    static notFound() {
        CoordMode("Pixel", "Screen")
        PixelGetColor(1, 1)
        ; check if it is not found ,which means, need to create share

        return
    }

    static search(roomNum, name := 0, roomLoopIndex := 0) {
        Send roomNum
        Sleep 200
        Send "{Tab}"
        Sleep 200
        Send name
        Sleep 200
        Send "!h" ; alt+h => search
        Sleep 200
    }

    static createShareIn(room) {
        ; TODO: create schedule

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