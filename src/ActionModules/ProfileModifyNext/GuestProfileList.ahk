GuestProfileList(App, db, listContent) {
    DEFAULT_LOAD_MIN := 60

    colTitleMap := (
        "name", "姓名",
        "roomNum", "房号",
        "gender", "性别",
        "birthday", "生日",
        "address", "地址",
        "idType", "证件类型",
        "idNum", "证件号码",
        "loggedTime", "登记时间"
    )

    colTitles := []
    for key, val in colTitleMap {
        colTitles.Push(val)
    }

    listInitialize() {
        LV := App.getCtrlByType("ListView")

        dataRead := []
        loop files db.centralPath . "*.json" {
            dataRead.Push(JSON.parse(FileRead(A_LoopFileFullPath)))
            if (DateDiff(A_Now, SubStr(A_LoopFileName, 1, 12), "M") > DEFAULT_LOAD_MIN) {
                break
            }
        }
        listContent.set(dataRead)

        for item in listContent.value {
            LV.Add(,
                item["name"],
                item["roomNum"],
                item["gender"],
                item["birthday"],
                item["address"],
                item["idType"],
                item["idNum"],
                item["loggedTime"],
            )
        }
    }

    return (
        App.AddListView("w430", colTitles),
        listInitialize()
    )
}