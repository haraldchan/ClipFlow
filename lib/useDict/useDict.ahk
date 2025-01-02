class Dict {
    static DICT_PATH := A_ScriptName == "useDict_Test.ahk" ? "./dictionaries" : A_ScriptDir . "\lib\useDict\dictionaries"

    static pinyin := JSON.parse(FileRead(this.DICT_PATH . "\pinyin.json", "UTF-8"))

    static pinyinWade := JSON.parse(FileRead(this.DICT_PATH . "\pinyin-wade.json", "UTF-8"))

    static doubleLastName := JSON.parse(FileRead(this.DICT_PATH . "\double-last-name.json", "UTF-8"))

    static tone := Map(
        "ā", "a",
        "á", "a",
        "ǎ", "a",
        "à", "a",
        "ē", "e",
        "é", "e",
        "ě", "e",
        "è", "e",
        "ī", "i",
        "í", "i",
        "ǐ", "i",
        "ì", "i",
        "ō", "o",
        "ó", "o",
        "ǒ", "o",
        "ò", "o",
        "ū", "u",
        "ú", "u",
        "ǔ", "u",
        "ù", "u",
    )

    static regionISO := JSON.parse(FileRead(this.DICT_PATH . "\region-iso.json", "UTF-8"))

    static provinces := JSON.parse(FileRead(this.DICT_PATH . "\provinces.json", "UTF-8"))

    static provinceWithCities := JSON.parse(FileRead(this.DICT_PATH . "\province-with-cities.json", "UTF-8"))

    static idTypes := JSON.parse(FileRead(this.DICT_PATH . "\id-types.json", "UTF-8"))
}

class useDict {
    /**
     * Convert a Hanzi character to pinyin.
     * @param {string} hanzi A chinese character to convert.
     * @param {boolean} useWG Uses Wade-Giles instead of Pinyin.
     * @returns {string} 
     */
    static getPinyin(hanzi, useWG := false) {
        for pinyin, hanCharacters in Dict.pinyin {
            if (InStr(hanCharacters, hanzi)) {
                return useWG == false ? pinyin : Dict.pinyinWade[pinyin]
            }
        }
        ; if not found in Dict, fetch from baidu hanyu
        return this.fetchPinyin(hanzi, useWG)
    }

    /**
     * Fetching pinyin of certain Hanzi from hanyu.baidu.com
     * @param hanzi A chinese character to convert.
     * @param {boolean} useWG Uses Wade-Giles instead of Pinyin.
     * @returns {String} 
     */
    static fetchPinyin(hanzi, useWG := false) {
        ; 360国学 
        url := Format("https://guoxue.baike.so.com/query/view?type=word&title={1}", hanzi)
        
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        html := ComObject("HTMLFile")

        whr.Open("POST", url, false)
        whr.Send()
        whr.WaitForResponse()
        page := whr.ResponseText
        html.Write(page)

        Sleep 500
        pinyinSpans := html.getElementsByTagName("span")
        loop pinyinSpans.Length {
            pinyinSpans[A_Index].dataFormatAs := "Text"
            pinyinField := pinyinSpans[A_Index].InnerText
            if (InStr(pinyinField, "[")) {
                toned := Trim(StrReplace(StrReplace(pinyinField, "[ "), "]"))
                break
            }
        }
        
        for tonedChar, char in Dict.tone {
            if (InStr(toned, tonedChar)) {
                unToned := Trim(StrReplace(toned, tonedChar, char))
            }
        }

        html := ""
        whr := ""

        ; update pinyin dictionary
        Dict.pinyin[unToned] := Dict.pinyin[unToned] . hanzi
        FileDelete(Dict.DICT_PATH . "\pinyin.json")
        FileAppend(JSON.stringify(Dict.pinyin), Dict.DICT_PATH . "\pinyin.json", "UTF-8")

        return useWG == false ? unToned : Dict.pinyinWade[unToned]
    }

    /**
     * Convert the pinyin of last name and first name.
     * @param {string} fullname The name to convert.
     * @param {boolean} useWG Uses Wade-Giles instead of Pinyin.
     * @returns {array} [last name, first name]
     */
    static getFullnamePinyin(fullname, useWG := false) {
        if (Dict.doubleLastName.Has(SubStr(fullname, 1, 2))) {
            lastname := Dict.doubleLastName[SubStr(fullname, 1, 2)]
            if (useWG == true) {
                lastname := StrSplit(lastname, " ").map(pinyin => Dict.pinyinWade[pinyin]).join("-")
            }
            lastnameLength := 2
        } else {
            lastname := this.getPinyin(SubStr(fullname, 1, 1), useWG)
            lastnameLength := 1
        }

        firstname := StrSplit(SubStr(fullname, lastnameLength + 1), "")
                     .map(hanzi => this.getPinyin(hanzi, useWG))
                     .join(useWG == false ? " " : "-")

        return [Trim(lastname), Trim(firstname)]
    }

    /**
     * Get the ISO 3166-1 alpha-2 regional code.
     * @param {string} country The chinese country name to convert.
     * @returns {any} 
     */
    static getCountryCode(country) {
        for region, code in Dict.regionISO {
            if (country = region) {
                return code
            }
        }
    }

    /**
     * Get the province name by address
     * @param {string} address 
     * @returns {any} 
     */
    static getProvince(address) {

        for province, code in Dict.provinces {
            if (InStr(address, province)) {
                if (code != "") {
                    return code
                }
            }
        }

        for code, cities in Dict.provinceWithCities {
            for city in cities {
                if (InStr(address, city)) {
                    return code
                }
            }
        }
    }

    static getIdTypeCode(idType) {
        for type, code in Dict.idTypes {
            if (type = idType) {
                return code
            }
        }
    }
}