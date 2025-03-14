ReservationDetails(App, curResv) {
    fieldIndex := OrderedMap(
        "resvType", "订单类型",
        "crewNames", "机组姓名",
        "tripNum", "Trip No.",
        "roomQty", "订房数量",
        "ciDate", "入住日期",
        "flightIn", "预抵航班",
        "ETA", "入住时间",
        "coDate", "退房日期",
        "flightOut", "离开航班",
        "ETD", "退房时间",
        "stayHours", "在住时长",
        "daysActual", "计费天数",
        "tracking", "Tracking 单号",
    )

    effect(curResv, cur => handleListUpdate(cur, fieldIndex))
    handleListUpdate(curResv, fieldIndex) {
        LV := App.getCtrlByType("ListView")
        LV.Delete()

        for key, field in fieldIndex {            
            if (key == "crewNames") {
                val := curResv[key].join(", ")
            } else if (key == "ciDate" || key == "coDate") {
                val := FormatTime(curResv[key], "yyyy/MM/dd")
            } else {
                val := curResv[key]
            }

            LV.Add(, field, val)
        }
    }

    return (
        App.AddListView("vresvDetailList Grid LV0x4000 NoSortHdr w310 r13 yp+30", ["预订项目", "预订详情"])
    )
}