/**
 * Test todos:
 * 1. getPartition method:
 *  - find closest partition correctly;
 *  - restore backup if partition is not found;
 *  - create new partition if no backup either.
 * 
 * 2. partition related:
 *  - how big is a 20-day partition;
 *  - how fast is load method in this way;
 *  - what's the bottleneck capacity(maximum splitDays).
 * 
 * 3. possible updates:
 *  - introduce a yyyy/mm/ dir structure for better grouping?
 *  - set maximum splitDays for better performance?
*/

#SingleInstance Force
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
; CreateBackupTest()


AddTest() {
    jsonString := FileRead("./20240826002540557.json", "UTF-8")
    date := FormatTime(A_Now, "yyyyMMdd")

    db.add(jsonString, date)
}
; AddTest()


AddConcurrentTest() {
    jsonStrings := FileRead("./20250203 - archive.json", "UTF-8")
    date := FormatTime(A_Now, "yyyyMMdd")

    for item in JSON.parse(jsonStrings) {
        sleep 500
        db.add(JSON.stringify(item), date)
    }
}
; AddConcurrentTest()


UpdateTest() {
    newJsonString := FileRead("./20240826002540557.json", "UTF-8")
    date := FormatTime(A_Now, "yyyyMMdd")

    updateFn(item) {
        return item["tsId"] == "1738584552100"
    }

    db.updateOne(newJsonString, date, updateFn)
}
; UpdateTest()


LoadTest() {
    LT := Gui(, A_ThisFunc)
    LT.OnEvent("Close", (*) => LT.Destroy())

    date := signal(A_Now)
    range := signal(999)
    data := signal(db.load(date.value, range.value))

    effect([date, range], (curDate, curRange) => data.set(db.load(curDate, curRange)))

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
        LT.AddDateTime().OnEvent("Change", (ctrl, _) => date.set(ctrl.Value)),
        LT.AddEdit("x+10 w60", range.value).OnEvent("LoseFocus", (ctrl, _) => range.set(Integer(ctrl.Value))),
        LT.Show()
    )
}
; LoadTest()