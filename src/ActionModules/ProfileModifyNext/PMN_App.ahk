#Include "./GuestProfileList.ahk"

PMN_App(App, popupTitle, db) {
    currentGuest := signal("")
    listContent := signal([])

    ; Capturing guest profile and saving it.
    OnClipboardChange (*) => listenCapture()

    listenCapture() {
        if (!InStr(A_Clipboard, ProfileModifyNext.identifier)) {
            return
        }
        currentGuest.set(JSON.parse(A_Clipboard))
        MsgBox(Format("已获取： {1}", currentGuest.value["name"]), popupTitle, "4096 T1")
    }

    saveCaptured(curGuest) {
        fileName := A_Now . A_MSec . ".json"
        FileAppend(JSON.stringify(curGuest), db.centralPath . "\" . FormatTime(A_Now, "yyyyMMdd") . "\" . fileName)
        FileAppend(JSON.stringify(curGuest), db.localPath . "\" . FormatTime(A_Now, "yyyyMMdd") . "\" . fileName)
    }

    effect(currentGuest, newGuest => saveCaptured(newGuest))

    ; re-render ListView when filtering/searching
    searchDate := signal(FormatTime(A_Now, "yyyyMMdd"))
    filter := signal({ search: "", period: 60 })

    handleQuery(filter := "", period := 60) {
        sleep 100

        LV := App.getCtrlByType("ListView")
        LV.Delete()
        dataRead := []

        if (filter = "") {
            loop files db.centralPath . "\" . searchDate.value . "\" . "*.json" {
                if (searchDate.value = FormatTime(A_Now, "yyyyMMdd") &&
                    DateDiff(A_Now, SubStr(A_LoopFileName, 1, 12), "M") > period
                ) {
                    break
                }

                dataRead.Push(JSON.parse(FileRead(A_LoopFileFullPath)))
            }
        } else {
            loop files db.centralPath . "\" . searchDate.value . "\" . "*.json" {
                if (searchDate.value = FormatTime(A_Now, "yyyyMMdd") &&
                    DateDiff(A_Now, SubStr(A_LoopFileName, 1, 12), "M") > period
                ) {
                    break
                }

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

    effect(filter, new => handleQuery(new.search, new.period))

    ; reset and update
    handleListReset() {
        filter.set({ search: "", period: 0 })
        App.getCtrlByName("search").value := filter.value.search
        App.getCtrlByName("period").value := filter.value.period
    }

    return (
        App.AddGroupBox("R18 w450 y+20", popupTitle),
        App.AddText("", "筛选姓名/房号"),
        App.AddDateTime("vdate", "ShortDate").OnEvent("Change", (d*) => searchDate.set(FormatTime(d[1].value, "yyyyMMdd"))),
        App.AddEdit("vsearch", filter.value.search).OnEvent("Change", (e*) => filter.set({ search: e[1].value, period: filter.value.period })),
        App.AddEdit("vperiod Number", filter.value.period).OnEvent("Change", (e*) => filter.set({ search: filter.value.search, period: e[1].value = "" ? 60 : e[1].value })),
        App.AddText("", "分钟内"),
        ; manual updating
        App.AddButton("", "更新").OnEvent("Click", (*) => handleListReset()),
        App.AddButton("", "填入"),
        GuestProfileList(App, db, listContent)
    )
}