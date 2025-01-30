#Include "../AddReactive/useAddReactive.ahk"
#Include "../useDateBase.ahk"

db := useDateBase({
    main: A_ScriptDir . "\main",
    backup: A_ScriptDir . "\backup"
})

CreateBackupTest() {
    date := FormatTime(A_Now, "yyyyMMdd")

    ; yesterday := FormatTime(DateAdd(Format(A_Now, "yyyyMMdd"), -1, "Days"), "yyyyMMdd")
    ; if (!FileExist(db.backup . "\" . SubStr(date, 1, 6) . "\" . date . "_backup.json")) {

    if (!FileExist(db.backup . "\" . SubStr(date, 1, 6) . "\" . date . "_backup.json")) {
        db.createBackup(date)
    }
}


; TODO: test if add works as expected when file attrib is set to "H"(hidden)
AddTest() {
    jsonString := ""
    date := FormatTime(A_Now, "yyyyMMdd") 

    db.add(jsonString, date)
}

AddConcurrentTest() {
    jsonStrings := []
    date:= FormatTime(A_Now, "yyyyMMdd")

    for item in jsonStrings {
        db.add(item, date)
    }
}


; TODO: test can it load correctly when add is executing.
; TODO: test loading using real data during Spring Fes
LoadTest() {
    date := FormatTime(A_Now, "yyyyMMdd")
    range := 60

    LT := Gui(, A_ThisFunc)
    LT.OnEvent("Close", (*) => LT.Destroy())

    data := signal(db.load(, date, range))

    columnDetails := {
        keys: ["roomNum", "name", "gender", "idType", "idNum", "addr"],
        titles: ["房号", "姓名", "性别", "类型", "证件号码", "地址"],
        widths: [60, 90, 40, 80, 145, 120]
    }

    options := {
        lvOptions: "$guestProfileList Grid -ReadOnly -Multi LV0x4000 w550 r15",
        itemOptions: ""
    }

    return (
        LT.ARListView(options, columnDetails, data),
        LT.Show()
    )
}

; TODO: test if add works as expected when file attrib is set to "H"(hidden)
UpdateTest() {
    newJsonString := ""
    date := FormatTime(A_Now, "yyyyMMdd")
    
    updateFn(item) {
        return item["nameLast"] == "Kramer" && item["idNum"] == "Axxxx"
    }

    db.updateOne(newJsonString, date, item => item["tsId"] == JSON.parse(newJsonString)["tsId"])
}