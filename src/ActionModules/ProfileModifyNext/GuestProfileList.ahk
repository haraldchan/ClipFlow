GuestProfileList(App, db, listContent) {
    DEFAULT_LOAD_MIN := 60

    colTitleMap := Map(
        "roomNum", "房号",
        "name", "姓名",
        "idType", "证件类型",
        "idNum", "证件号码",
        "addr", "地址",
    )

    handleListInitialize() {
        LV := App.getCtrlByType("ListView")

        listContent.set(db.load())
        for item in listContent.value {
            listName := item["guestType"] = "国外旅客"
                ? item["nameLast"] . ", " . item["nameFirst"]
                : item["name"]

            LV.Add(,
                item["roomNum"],
                listName,
                item["idType"],
                item["idNum"],
                item["addr"],
            )
        }
        ; column width setting
        LV.ModifyCol(1, 50)
        LV.ModifyCol(2, 100)
        LV.ModifyCol(3, 80)
        LV.ModifyCol(4, 180)
        LV.ModifyCol(5, 115)

        LV.Modify(1, "Select")
        LV.Focus()
    }

    return (
        App.AddListView("w530 h360 xp-452 y+10", ["房号", "姓名", "类型", "证件号码", "地址"]),
        handleListInitialize()
    )
}