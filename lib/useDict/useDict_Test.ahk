#Include "./useDict.ahk"
#Include "../AddReactive/AddReactive.ahk"

UseDictTest() {
    UDT := Gui()
    Dict.DICT_PATH := "./dictionaries"
    pinyin := signal("")

    handlePinyinConver(*) {
        hanChar := UDT.getCtrlByName("hanChar")
        if (StrLen(hanChar) > 1) {
            MsgBox("请输入单个汉字！",,"4096 T1")
        }

        pinyin.set(useDict.getPinyin(hanChar))
    }

    return (
        UDT.AddText("w200 h30", "请输入单个汉字："),
        UDT.AddEdit("vhanChar y+10 w40 h30", ""),
        UDT.AddReactiveText("x+10 w40 h30", "{1}", pinyin),
        UDT.AddButton("y+10 w100 h40", "转换拼音")
    )
}

UseDictTest()