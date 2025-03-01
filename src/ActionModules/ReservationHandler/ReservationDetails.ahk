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
        "remarks", "备注信息"
    )

    effect(curResv, cur => handleListUpdate(cur, fieldIndex))
    handleListUpdate(curResv, fieldIndex) {
        LV := App.getCtrlByType("ListView")
        LV.Delete()

        for key, field in fieldIndex {
            LV.Add(, field, curResv[key])
        }
    }

    onMount() {
        LV := App.getCtrlByType("ListView")
        LV.SetFont("s10.5")
        LV.ModifyCol(1, 80)
        LV.ModifyCol(2, 220)
        
        useListPlaceholder(curResv, fieldIndex.keys(), "")
    }

    return (
        App.AddListView("vresvDetailList Grid w300 r14 y+20", ["预订项目", "预订详情"]),
        onMount()
    )
}