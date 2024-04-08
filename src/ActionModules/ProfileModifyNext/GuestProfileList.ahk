GuestProfileList(App, db, listContent) {
    DEFAULT_LOAD_MIN := 60

    colTitleMap := (
        "roomNum", "房号",
        "name", "姓名",
        "idType", "证件类型",
        "idNum", "证件号码",
        "address", "地址",
    )

    colTitles := []
    for key, val in colTitleMap {
        colTitles.Push(val)
    }

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
                item["address"],
            )
        }
    }

    return (
        App.AddListView("w430", colTitles),
        handleListInitialize()
    )
}