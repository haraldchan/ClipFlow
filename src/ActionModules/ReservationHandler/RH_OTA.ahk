#Include "./RH_OtaBookingEntry.ahk"

class RH_OTA {
    static USE(curResv, splitParty := false) {
        if (curResv["agent"] == "kingsley") {
            this.WholeSale(curResv, splitParty)
        }

    }

    static roomTypeRefs := Map(
        "kingsley", Map(
            "标准大床房", "SKC",
            "标准双床房", "STC",
            "豪华城景大床房", "DKC",
            "豪华城景双床房", "DTC",
            "豪华江景大床房", "DKR",
            "豪华江景双床房", "DTR",
            "行政豪华城景大床房", "CKC",
            "行政豪华城景双床房", "CTC",
            "行政豪华江景大床房", "CKR",
            "行政豪华江景双床房", "CTR",
            "行政尊贵套房", "CSK"
        ),
        "jielv", Map(
            "城市景观标准大床房", "SKC",
            "城市景观标准双床房", "STC",
            "豪华城景大床房", "DKC",
            "豪华城景双床房", "DTC",
            "江景豪华大床房", "DKR",
            "江景豪华双床房", "DTR",
            "行政豪华城景大床房", "CKC",
            "行政豪华城景双床房", "CTC",
            "行政豪华江景大床房", "CKR",
            "行政豪华江景双床房", "CTR",
            "行政尊贵套房", "CSK"
        )
    )

    static WholeSale(curResv, splitParty) {
        ; convert roomType
        roomType := this.roomTypeRefs[curResv["agent"]]

        ; define breakfast comment
        breakfastType := (SubStr(roomType, 1, 1) = "C") ? "CBF" : "BBF"
        breakfastQty := curResv["bbf"][1]
        comment := (breakfastQty == 0) ? "RM TO TA" : Format("RM INCL {1}{2} TO TA", breakfastQty, breakfastType)

        ; reformat guest names
        pmsGuestNames := []
        loop curResv["guestNames"].Length {
            curGuestName := curResv["guestNames"][A_Index]
            if (RegExMatch(curGuestName, "^[a-zA-Z/]+$") > 0) {
                ; if only includes English alphabet, push [lastName, firstName]
                pmsGuestNames.Push(StrSplit(curGuestName, "/"))
            } else {
                unpack([&lastName, &firstName], useDict.getFullnamePinyin(curGuestName))
                pmsGuestNames.Push([lastName, firstName, curGuestName])
            }
        }

        ; Main booking modification
        RH_OtaBookingEntry.USE(
            curResv,
            roomType,
            comment,
            pmsGuestNames,
            splitParty
        )
    }
}