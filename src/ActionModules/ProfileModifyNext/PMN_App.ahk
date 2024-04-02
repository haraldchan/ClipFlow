#Include "./GuestProfileList.ahk"

PMN_App(App, popupTitle, db) {
    currentGuest := signal("")
    listContent := signal([])
    OnClipboardChange (*) => currentGuest.set(JSON.parse(A_Clipboard))

    saveCaptured(curGuest) {
        fileName := A_Now . A_MSec . ".json"
        FileAppend(JSON.stringify(curGuest), db.centralPath . "\" . FormatTime(A_Now, "yyyyMMdd") . "\" . fileName)
        FileAppend(JSON.stringify(curGuest), db.localPath . "\" . FormatTime(A_Now, "yyyyMMdd") . "\" . fileName)
    }

    effect(currentGuest, newGuest => saveCaptured(newGuest))

    searchDate := signal(FormatTime(A_Now, "yyyyMMdd"))
    searchFilter := signal("")
    searchPeriod := signal(60)

    handleQuery(filter := "", period := 60) {
        sleep 100
        
        LV := App.getCtrlByType("ListView")
        LV.Delete()
        dataRead := []

        if (filter = "") {
            loop files db.centralPath . "\" . FormatTime(A_Now, "yyyyMMdd") . "\" . "*.json" {
                dataRead.Push(JSON.parse(FileRead(A_LoopFileFullPath)))
                if (DateDiff(A_Now, SubStr(A_LoopFileName, 1, 12), "M") > period) {
                    break
                }
            }
        } else {
            loop files db.centralPath . "\" . searchDate.value . "\" . "*.json" {
                guestRead := JSON.parse(FileRead(A_LoopFileFullPath))
                if (filter is Number) {
                    if (InStr(guestRead["roomNum"], filter)) {
                        dataRead.Push(guestRead)
                    }
                } else {
                    if (InStr(guestRead["name"], filter)) {
                        dataRead.Push(guestRead)
                    }
                }
                if (DateDiff(A_Now, SubStr(A_LoopFileName, 1, 12), "M") > period) {
                    break
                }
            }
        }

        listContent.set(dataRead)

        if (listContent.value != []) {
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
    }

    effect(searchFilter, handleQuery(searchFilter.value, searchPeriod.value))
    effect(searchPeriod, handleQuery(searchFilter.value, searchPeriod.value))

    return (
        App.AddGroupBox("R18 w450 y+20", popupTitle),
        App.AddText("", "筛选姓名/房号"),
        App.AddDateTime("vdate", "ShortDate").OnEvent("Change", (d*) => searchDate.set(FormatTime(d[1].value, "yyyyMMdd"))),
        App.AddEdit("vfilter", searchFilter.value).OnEvent("Change", (e*) => searchFilter.set(e[1].value)),
        App.AddEdit("vperiod Number", searchPeriod.value).OnEvent("Change", (e*) => searchPeriod.set(e[1].value = "" ? 60 : e[1].value)),
        App.AddText("", "分钟内"),
        App.AddButton("", "更新").OnEvent("Click", (*) => handleQuery(searchFilter.value, searchPeriod)),
        App.AddButton("", "填入"),
        GuestProfileList(App, db, listContent)
    )
}