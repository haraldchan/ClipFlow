#Include "./RH_Models.ahk"

ReservationDetails(App, curResv) {

    effect(curResv, cur => handleListUpdate(cur))
    handleListUpdate(curResv) {
        LV := App.getCtrlByType("ListView")
        LV.Delete()

        if (curResv["agent"] == "fedex") {
            for key, field in RH_Models.fedexListFields {
                if (key == "crewNames") {
                    val := curResv[key].join(", ")
                } else if (key == "ciDate" || key == "coDate") {
                    val := FormatTime(curResv[key], "yyyy/MM/dd")
                } else {
                    val := curResv[key]
                }

                LV.Add(, field, val)
            }
        } else {
            for key, field in RH_Models.otaListFields {
                if (key == "guestNames" || key == "roomRates") {
                    val := curResv[key].join(", ")
                } else if (key == "ciDate" || key == "coDate") {
                    val := FormatTime(curResv[key], "yyyy/MM/dd")
                } else if (key == "bbf") {
                    val := curResv[key].map(item => item == 0 ? "无早" : item == 1 ? "单早" : "双早").join(", ")
                } else {
                    val := curResv[key]
                }

                LV.Add(, field, val)
            }
        }
    }

    return (
        App.AddListView("vresvDetailList Grid LV0x4000 NoSortHdr w310 r13 yp+30", ["预订项目", "预订详情"])
    )
}