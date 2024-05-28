class BatchData {
    static reportFiling(frTime, toTime, initX := 433, initY := 598) {
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
        this.saveDeps(frTime, toTime)
        saveFileName := Format("{1} - Departures", FormatTime(A_Now, "yyyyMMdd")) . ".XML"

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

    ; TODO: rewrite with new ui
    static saveDeps(frTime, toTime) {
        WinSetAlwaysOnTop false, "ahk_class SunAwtFrame"
        BlockInput false

        Sleep 1000
        WinSetAlwaysOnTop true, "ahk_class SunAwtFrame"
        BlockInput true

        WinActivate "ahk_class SunAwtFrame"
        Sleep 100
        MouseMove 490, 363
        Sleep 100
        Click 3
        Sleep 100
        Send Format("{Text}{1}", frTime)
        Sleep 100
        Send "{Tab}"
        Sleep 100
        Send Format("{Text}{1}", toTime)
        Sleep 100
        loop 7 {
            Send "{Tab}"
            Sleep 100
        }
        Send "{Space}"
        Sleep 100
        Send "{Tab}"
        Sleep 100
        Send "{Space}"
    }

    static getDepartures(xmlPath) {
        departedGuests := []
        xmlDoc := ComObject("msxml2.DOMDocument.6.0")
        xmlDoc.async := false
        xmlDoc.load(xmlPath)
        roomElements := xmlDoc.getElementsByTagName("ROOM")
        nameElements := xmlDoc.getElementsByTagName("GUEST_NAME") 

        loop roomElements.Length {
            try { ;TODO: parsing will be error somehow, yet it is readable
                roomNum := roomElements[A_Index - 1].ChildNodes[0].nodeValue
                fullname := nameElements[A_Index - 1].ChildNodes[0].nodeValue
                nameLast := StrReplace(StrSplit(fullname, ",")[1], "*", "")
                nameFirst := StrSplit(fullname, ",")[2]
            }

            departedGuests.Push(Map(
                "roomNum", roomNum,
                "name", StrReplace(fullname, "`n", " "),
                "nameLast", nameLast,
                "nameFirst", nameFirst
                )
            )
        }

        return departedGuests
    }

    static getDepartedIdsAll(db, departedGuests) {
        dGuest := signal(Map())

        SEARCH_DAYS := 7
        
        guestInfosByDay := []
        today := FormatTime(A_Now, "yyyyMMdd")
        loop SEARCH_DAYS {
            try{
                guestInfosByDay.Push(
                    db.loadArchive(FormatTime(DateAdd(today, 0 - A_Index, "Days"), "yyyyMMdd"))
                )       
            }
        }

        guestIds := []

        for depGuest in departedGuests {
            dGuest.set(depGuest)

            for singleDay in guestInfosByDay {
                ; TODO: or using name to match?
                target := singleDay.find(guest => this.matchGuest(guest, dGuest.value))
                if (target != "") { 
                    guestIds.Push(target)
                    break
                } 
            }
        }
        return guestIds
    }

    ;TODO can't return correct ids
    static matchGuest(guest, depGuest){
        if (guest["guestType"] = "内地旅客") {
            if (useDict.getFullnamePinyin(guest["name"])[1] = depGuest["nameLast"] &&
                useDict.getFullnamePinyin(guest["name"])[2] = depGuest["nameFirst"]
                ) {
                return true
            } else {
                return false 
            }
            
        } else {
            if (guest["nameLast"] = depGuest["nameLast"] &&
                guest["nameFirst"] = depGuest["nameFirst"]
                ) {
                return true
            } else {
                return false 
            }
        }
    }
}