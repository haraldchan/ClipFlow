#Include "./GuestProfileList.ahk"

PMN_App(App, popupTitle, db, identifier) {
    currentGuest := signal("")
    listContent := signal([])
    queryFilter := signal({
        date: FormatTime(A_Now, "yyyyMMdd"),
        nameRoom: "",
        period: 60
    })

    OnClipboardChange (*) => handleCaptured(identifier, db, currentGuest)
    handleCaptured(identifier, db, currentGuest) {
        if (!InStr(A_Clipboard, identifier)) {
            return
        }
        ; save to db
        currentGuest.set(JSON.parse(A_Clipboard))
        db.add(A_Clipboard)
    }

    ; ideally, when the window is called or update button clicked, listContent should update
    handleListContentUpdate() {
        loadedItems := db.load(, queryFilter.value.date, queryFilter.value.period)
        filteredItems := []

        if (queryFilter.value.nameRoom = "") {
            filteredItems := loadedItems
        } else if (queryFilter.value.nameRoom is Number) {
            for item in loadedItems {
                if (InStr(item["roomNum"], queryFilter.value.nameRoom)) {
                    filteredItems.Push(item)
                }
            }
        } else {
            for item in loadedItems {
                if (InStr(item["name"], queryFilter.value.nameRoom) ||
                    InStr(item["nameLast"], queryFilter.value.nameRoom) ||
                    InStr(item["nameFirst"], queryFilter.value.nameRoom)
                ) {
                    filteredItems.Push(item)
                }
            }
        }
        listContent.set(filteredItems)
    }

    handleListItemsUpdate(updatedData) {
        LV := App.getCtrlByType("ListView")

        for item in updatedData {
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
    }

    effect(listContent, updated => handleListItemsUpdate(updated))

    return (
        App.AddGroupBox("R18 w450 y+20", popupTitle),
        ; date
        App.AddDateTime("vdate", "ShortDate Choose" . queryFilter.value.date).OnEvent("Change", (d*) => queryFilter.set({
            date: FormatTime(d[1].value, "yyyyMMdd"),
            nameRoom: queryFilter.value.nameRoom,
            period: queryFilter.value.period
        })),
        ; name or room number
        App.AddText("", "筛选姓名/房号"),
        App.AddEdit("vnameRoom", queryFilter.value.nameRoom).OnEvent("Change", (e*) => queryFilter.set({
            date: queryFilter.value.date,
            nameRoom: e[1].value,
            period: queryFilter.value.period
        })),
        ; period
        App.AddEdit("vperiod Number", queryFilter.value.period).OnEvent("Change", (e*) => queryFilter.set({
            date: queryFilter.value.date,
            nameRoom: queryFilter.value.nameRoom,
            period: e[1].value
        })),
        ; manual updating
        App.AddButton("vupdate", "更新").OnEvent("Click", (*) => handleListContentUpdate()),
        App.AddButton("vfillIn", "填入"),
        GuestProfileList(App, db, listContent)
    )
}