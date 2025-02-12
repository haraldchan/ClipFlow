class PMN_Waterfall {
    static cascade(rooms, selectedGuests, isOverwrite, party := 0) {
        PMN_FillIn.start()

        curRoom := signal(0)
        index := 1

        for room in rooms {
            curRoom.set(room)

            for guest in selectedGuests {
                remaining := selectedGuests.filter(g => g["roomNum"] = curRoom.value).Length

                if (guest["roomNum"] == curRoom.value) {
                    this.search(room, index, party)
                    if (!PMN_FillIn.isRunning) {
                        msgbox("脚本已终止", popupTitle, "4096 T1")
                        return
                    }
                    utils.waitLoading()
                    this.modify(guest, isOverwrite)
                    if (!PMN_FillIn.isRunning) {
                        msgbox("脚本已终止", popupTitle, "4096 T1")
                        return
                    }

                    guest["roomNum"] := ""
                    index := (remaining == 1) ? 1 : index + 1

                    if (remaining == 1) {
                        break
                    }
                }
            }
        }

        PMN_FillIn.end()
        MsgBox("已完成全部选中 Profile 录入。", "Waterfall cascaded", "4096 T1")
    }

    static search(roomNum, index, party := 0) {
        formattedRoom := StrLen(roomNum) = 3 ? "0" . roomNum : roomNum

        MouseMove 329, 196 ; room number field
        Click 3
        utils.waitLoading()
        if (!PMN_FillIn.isRunning) {
            msgbox("脚本已终止", popupTitle, "4096 T1")
            return
        }

        Send formattedRoom
        utils.waitLoading()

        if (party) {
            ; TODO: move to party and enter it if with party
        }

        Send "!h" ; alt+h => search
        utils.waitLoading()
        if (!PMN_FillIn.isRunning) {
            msgbox("脚本已终止", popupTitle, "4096 T1")
            return
        }

        ; sort by Prs.
        Click 838, 378, "Right" 
        utils.waitLoading()
        Send "{Down}"
        utils.waitLoading()
        Send "{Enter}"
        utils.waitLoading() 
        if (!PMN_FillIn.isRunning) {
            msgbox("脚本已终止", popupTitle, "4096 T1")
            return
        }

        ; choose resv
        loop (index - 1) {
            Send "{Down}"
            utils.waitLoading()
        }
    }

    static modify(guest, isOverwrite) { 
        Send "!p" ; open profile
        utils.waitLoading()
        
        PMN_FillIn.fill(guest, isOverwrite, true)
        utils.waitLoading()
        ; Sleep 1000

        Send "!o" ; ok
        utils.waitLoading()
        ; sleep 1000
    }
}