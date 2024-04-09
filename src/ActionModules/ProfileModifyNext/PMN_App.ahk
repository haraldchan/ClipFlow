#Include "./GuestProfileList.ahk"
#Include "./PMN_FillIn.ahk"

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
        handleListItemsUpdate()
    }

    ; ideally, when the window is called or update button clicked, listContent should update
    handleListContentUpdate() {
        loadedItems := db.load(, queryFilter.value["date"], queryFilter.value["period"])
        filteredItems := []

        typeConvert(content){
            converted := ""
            try {
                converted := Number(content)
            } catch {
                converted := content
            }
            return converted
        }

        searchInput := typeConvert(queryFilter.value["nameRoom"])

        if (searchInput = "") {
            ; no search value
            filteredItems := loadedItems
        } else if (searchInput is Number) {
            ; searching by room number
            for item in loadedItems {
                if (InStr(item["roomNum"], searchInput)) {
                    filteredItems.unshift(item)
                }
            }
        } else {
            ; searching by name fragment
            for item in loadedItems {
                if (item["guestType"] = "内地旅客") {
                    ; from mainland

                    if (InStr(item["name"], searchInput)) {
                        filteredItems.unshift(item)
                        continue
                    }
                } else if (item["guestType"] = "港澳台旅客") {
                    ; from HK/MO/TW
                    if (InStr(item["name"], searchInput) || 
                        InStr(item["nameLast"], searchInput, "Off") ||
                        InStr(item["nameFirst"], searchInput, "Off")
                    ) {
                        filteredItems.unshift(item)
                        continue
                    }          
                } else {
                    ; from abroad
                    if (InStr(item["nameLast"], searchInput, "Off") ||
                        InStr(item["nameFirst"], searchInput, "Off")
                    ) {
                        filteredItems.unshift(item)
                    }                       
                }                
            }
        }

        listContent.set(filteredItems)
    }

    handleListItemsUpdate() {
        handleListContentUpdate()
        LV := App.getCtrlByType("ListView")
        LV.Delete()

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

        LV.Modify(1, "Select")
        LV.Focus()
    }

    fillSelectedGuest(){
        LV := App.getCtrlByType("ListView")
        if (LV.GetNext() = 0) {
            return
        }
        PMN_Fillin.fill(listContent.value[LV.GetNext()])
    }

    return (
        App.AddGroupBox("R17 w550 y+20", popupTitle),
        ; date
        App.AddDateTime("vdate xp+10 yp+25 w100 h25 Choose" . queryFilter.value["date"]).OnEvent("Change", (d*) => queryFilter.set({
            date: FormatTime(d[1].value, "yyyyMMdd"),
            nameRoom: queryFilter.value["nameRoom"],
            period: queryFilter.value["period"]
        })),
        ; name or room number
        App.AddText("x+10 yp+5 h20", "姓名/房号"),
        App.AddEdit("vnameRoom x+5 yp-5 w100 h25", queryFilter.value["nameRoom"]).OnEvent("Change", (e*) => queryFilter.set({
            date: queryFilter.value["date"],
            nameRoom: e[1].value,
            period: queryFilter.value["period"]
        })),
        ; period
        App.AddText("x+10 yp+5 h20", "最近"),
        App.AddEdit("vperiod Number x+1 yp-5 w30 h25", queryFilter.value["period"]).OnEvent("Change", (e*) => queryFilter.set({
            date: queryFilter.value["date"],
            nameRoom: queryFilter.value["nameRoom"],
            period: e[1].value = "" ? 7200 : e[1].value
        })),
        App.AddText("x+1 yp+5 h25", "分钟"),
        ; manual updating
        App.AddButton("vupdate x+10 yp-8 w80 h30", "刷 新(&R)").OnEvent("Click", (*) => handleListItemsUpdate()),
        App.AddButton("vfillIn x+5 w80 h30 Default", "填 入").OnEvent("Click", (*) => fillSelectedGuest()),
        GuestProfileList(App, db, listContent)
    )
}