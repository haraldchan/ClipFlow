#Include "./RH_OtaBookingEntry.ahk"

class RH_OTA {
    static supportList := [
        "jielv", 
        "kingsley",
        "ctrip-ota"
    ]

    static USE(curResv, splitParty := false, withRemarks := false, packages := "") {
        if (!this.supportList.find(agent => agent == curResv["agent"])) {
            return
        }

        this.parseReservation(curResv, splitParty, withRemarks, packages)
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
        ),
        "ctrip-ota", Map(
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
        "ctrip-business", Map(
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
    )

    static parseReservation(curResv, splitParty, withRemarks, packages) {
        ; convert roomType
        roomType := this.roomTypeRefs[curResv["agent"]][curResv["roomType"]]

        ; define breakfast type
        breakfastType := (roomType.substr(1, 1) == "C") ? "CBF" : "BBF"
        breakfastQty := curResv["bbf"][1]

        ; comment formatting
        comment := ""
        if (curResv["payment"] == "预付") {
            comment := (breakfastQty == 0) ? "RM TO TA" : Format("RM INCL {1}{2} TO TA", breakfastQty, breakfastType)
        } else {
            comments := []
            roomTotal := curResv["roomRates"].Length > 1 
                ? Format("Total:RMB{} || ", curResv["roomRates"].reduce((acc, cur) => acc + cur, 0))
                : ""

            loop curResv["roomRates"].Length {
                date := FormatTime(DateAdd(curResv["ciDate"], A_Index - 1, "Days"), "MM/dd")
                datePrint := ""
                rate := curResv["roomRates"][A_Index]

                if (A_Index > 1 && rate == curResv["roomRates"][A_Index - 1]) {
                    prevDate := comments.at(-1)[1]
                    datePrint := prevDate.includes("-") 
                        ? prevDate.split("-")[1] . "-" . date
                        : prevDate . "-" . date
                    
                    comments[comments.Length][1] := datePrint
                } else {
                    comments.Push([date, rate])
                }
            }

            comment := roomTotal . comments.map(cmmt => Format("{1}:RMB{2}net{3}", cmmt[1], cmmt[2], breakfastQty > 0 ? " INCL " . breakfastQty . breakfastType : "")).join("; ")
        }

        if (withRemarks) {
            comment .= ", " . curResv["remarks"]
        }

        ; reformat guest names
        pmsGuestNames := []
        loop curResv["guestNames"].Length {
            curGuestName := curResv["guestNames"][A_Index].trim()
            if (RegExMatch(curGuestName, "^[a-zA-Z/ ]+$") > 0) {
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
            splitParty,
            packages
        )
    }
}
