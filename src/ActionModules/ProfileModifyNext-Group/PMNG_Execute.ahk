#Include "../ProfileModifyNext/PMN_FillIn.ahk"
class PMNG_Execute {
    static startModify(groupName, inhRooms, groupGuests) {
        for room in inhRooms {
            for guest in groupGuests {
                if (guest["roomNum"] = room) {
                    this.search(room, A_Index = 1 ? groupName : 1)
                    if (this.notFound() = true) {
                        this.search(room)
                        this.createShareIn(room)
                    }
                    Sleep 500
                    this.modify()
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

    static search(roomNum, name, roomLoopIndex) {
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
        ; pending

    }

    static modify(guest) {
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
        
        loop 10 {
            Sleep 1000
            if(!anchorIsVisible) {
                break
            }
        }

        Send "!r" ; clear
    }
}