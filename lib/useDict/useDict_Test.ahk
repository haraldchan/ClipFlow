#SingleInstance Force
#Include "./useDict.ahk"
#Include "../AddReactive/AddReactive.ahk"

UseDictTest() {
    UDT := Gui()
    fullname := signal({last: "", first: ""})

    handlePinyinConver(*) {
        form := UDT.submit()
        name := useDict.getFullnamePinyin(form.hanChar, form.useWG)

        fullname.set({last: name[1], first: name[2]})
    }

    return (
        UDT.AddCheckbox("vuseWG w200 h30", "使用威妥玛拼音"),
        UDT.AddText("w200 h30", "请输入全名："),
        UDT.AddEdit("vhanChar x10 y+10 w100 h25", ""),
        UDT.AddReactiveText("x+10 w100 h25", "{1} {2}", fullname, ["last", "first"]),
        UDT.AddButton("x10 y+10 w100 h40", "转换拼音").OnEvent("Click", handlePinyinConver),
        UDT.Show()
    )
}

UseDictTest()
