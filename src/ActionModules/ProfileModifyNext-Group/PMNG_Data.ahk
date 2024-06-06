class PMNG_Data {
    static reportFiling(blockcode, initX := 433, initY := 598) {
        WinSetAlwaysOnTop true, "ahk_class SunAwtFrame"
        BlockInput true
        WinMaximize "ahk_class SunAwtFrame"
        WinActivate "ahk_class SunAwtFrame"
        Sleep 100
        Send "!m"
        Sleep 100
        Send "{Text}R"
        Sleep 100
        Send Format("{Text}{1}", "FO03")
        Sleep 100
        Send "!h"
        Sleep 100
        MouseMove initX, initY ; 433, 598
        Sleep 150
        Click ; click print to file
        Sleep 150

        MouseMove initX + 380, initY
        Click
        loop 2 {
            Send "{Down}"
            Sleep 10
        }
        Sleep 100
        Send "{Enter}"
        Sleep 100
        Send "!o"

        ; run saving actions, return filename
        this.saveGroupInhouse(blockcode)
        saveFileName := blockcode . ".XML"

        Sleep 1000
        Send "!f"
        Sleep 1000
        Send "{Backspace}"
        Sleep 200
        Send Format("{Text}{1}", saveFileName)
        Sleep 1000
        Send "{Enter}"
        TrayTip Format("正在保存：{1}", saveFileName)

        isWindows7 := StrSplit(A_OSVersion, ".")[1] = 6
        loop 30 {
            sleep 1000

            if (!isWindows7 && WinExist("Warning")) {
                WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"
                WinSetAlwaysOnTop true, "Warning"
                Sleep 100
                Send "{Enter}"
                Sleep 100
                WinSetAlwaysOnTop true, "ahk_class SunAwtFrame"
            }

            if (FileExist(A_MyDocuments . "\" . saveFileName)) {
                break
            }

            if (A_Index = 30) {
                MsgBox("保存出错，脚本已终止。", "ReportMaster", "T1 4096")
                utils.cleanReload(winGroup)
            }
        }

        Sleep 200
        MouseMove initX, initY ; WIP
        Click
        Sleep 200
        Send "!c"
        BlockInput false
        WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"
    }

    static saveGroupInhouse(blockcode) {
        ; save in group options
    }

    static getGroupHouseInformations(xmlPath) {
        xmlDoc := ComObject("msxml2.DOMDocument.6.0")
        xmlDoc.async := false
        xmlDoc.load(xmlPath)
        roomElements := xmlDoc.getElementsByTagName("ROOM")
        groupNameElements := xmlDoc.getElementsByTagName("GROUP_NAME")
        
        groupName := Trim(groupNameElements[0].ChildNodes[0].nodeValue)
        
        inhRooms := []
        loop roomElements.Length {
            roomNumString := roomElements[A_Index - 1].ChildNodes[0].nodeValue
            roomNum := (SubStr(roomNumString, 0, 1) = "0")
                ? SubStr(roomNumString, 1)
                : roomNumString

            inhRooms.Push(roomNum)
        }

        return Map("groupName", groupName, "inhRooms", inhRooms)
    }

    static getGroupGuests(db, inhRooms) {
        ; roomNums := inhRooms.map(room => room.roomNum).unique()
        loadedGuests := db.load(, FormatTime(A_Now, "yyyyMMdd"), 1440)

        groupGuests := []
        for roomNum in inhRooms {
            for guest in loadedGuests {
                if (StrLen(guest["roomNum"]) = 3) {
                    guest["roomNum"] := "0" . guest["roomNum"]
                }
                if (guest["roomNum"] = roomNum) {
                    groupGuests.Push(guest)
                }
            }
        }

        return groupGuests
    }
}