class Dict {
    static DICT_PATH := A_ScriptDir . "\lib\useDict\dictionaries"
    ; static DICT_PATH := "./dictionaries"

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
     * @returns {string} 
     */
    static getPinyin(hanzi, useWade := false) {
        for pinyin, hanCharacters in Dict.pinyin {
            if (InStr(hanCharacters, hanzi)) {
                return useWade == false ? pinyin : Dict.pinyinWade[pinyin]
            }
        }
        ; if not found in Dict, fetch from baidu hanyu
        return this.fetchPinyin(hanzi, useWade)
    }

    /**
     * Fetching pinyin of certain Hanzi from hanyu.baidu.com
     * @param hanzi A chinese character to convert.
     * @returns {String} 
     */
    static fetchPinyin(hanzi, useWade := false) {
        url := Format("https://hanyu.baidu.com/zici/s?wd={1}", hanzi)
        isWindows7 := StrSplit(A_OSVersion, ".")[1] = 6

        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        html := ComObject("HTMLFile")

        loop {
            whr.Open("POST", url, false)
            whr.Send()
            whr.WaitForResponse()
            page := whr.ResponseText
            html.Write(page)

            if (html.getElementById("pinyin") = "") {
                Sleep 500
                continue
            } else {
                toned := StrSplit(html.getElementById("pinyin").InnerText, " ")[1]
                break
            }
        }

        unToned := ""
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

        return useWade == false ? unToned : Dict.pinyinWade[unToned]
    }

    /**
     * Convert the pinyin of last name and first name.
     * @param {string} fullname The name to convert.
     * @returns {array} [last name, first name]
     */
    static getFullnamePinyin(fullname, useWade := false) {
        if (Dict.doubleLastName.Has(SubStr(fullname, 1, 2))) {
            lastname := Dict.doubleLastName[SubStr(fullname, 1, 2)]
            lastnameLength := 2
        } else {
            lastname := this.getPinyin(SubStr(fullname, 1, 1), useWade)
            lastnameLength := 1
        }

        firstname := StrSplit(SubStr(fullname, lastnameLength + 1), "")
                     .map(hanzi => this.getPinyin(hanzi, useWade))
                     .join(useWade == false ? " " : "-")

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
