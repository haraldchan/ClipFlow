class PMNG_Data {
    static reportFilling(blockcode) {
        ; save the xml
    }

    static saveGroupInhouse(blockcode) {
        ; save in group options
    }

    static getGroupHouseInformations(xmlPath) {
        inhRooms := []
        xmlDoc := ComObject("msxml2.DOMDocument.6.0")
        xmlDoc.async := false
        xmlDoc.load(xmlPath)
        roomElements := xmlDoc.getElementsByTagName("ROOM")
        dummyNameElements := xmlDoc.getElementsByTagName("")
        groupNameElements := xmlDoc.getElementsByTagName("")
        
        groupName := groupNameElements[0].ChildNodes[0].nodeValue
        dummyName := StrSplit(dummyNameElements[0].ChildNodes[0].nodeValue, " ")[0]
        
        loop roomElements.Length {
            roomNumString := roomElements[A_Index - 1].ChildNodes[0].nodeValue
            roomNum := (SubStr(roomNumString, 0, 1) = "0")
                ? SubStr(roomNumString, 1)
                : roomNumString

            inhRooms.Push(Map("roomNum", roomNum))
        }

        return Map("groupName", groupName, "dummyName", dummyName, "inhRooms", inhRooms)
    }

    static getGroupGuests(db, inhRooms) {
        roomNums := inhRooms.map(room => room.roomNum).unique()
        loadedGuests := db.load(, FormatTime(A_Now, "yyyyMMdd"), 1440)

        groupGuests := []
        for roomNum in roomNums {
            for guest in loadedGuests {
                if (guest["roomNum"] = roomNum) {
                    groupGuests.Push(guest)
                }
            }
        }

        return groupGuests
    }
}