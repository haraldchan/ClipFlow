class Dict {
    static DICT_PATH := A_ScriptDir . "\lib\useDict\dictionaries"

    static pinyin := JSON.parse(FileRead(this.DICT_PATH . "\pinyin.json", "UTF-8"))

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
        "ū", "i",
        "ú", "i",
        "ǔ", "i",
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
    static getPinyin(hanzi) {
        for pinyin, hanCharacters in Dict.pinyin {
            if (InStr(hanCharacters, hanzi)) {
                return pinyin
            }
        }
        ; if not found in Dict, fetch from baidu hanyu
        return this.fetchPinyin(hanzi)
    }

    /**
     * Fetching pinyin of certain Hanzi from hanyu.baidu.com
     * @param hanzi A chinese character to convert.
     * @returns {String} 
     */
    static fetchPinyin(hanzi) {
        url := Format("https://hanyu.baidu.com/zici/s?wd={1}", hanzi)

        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        html := ComObject("HTMLFile")

        notifier := () => TrayTip(Format("正在获取 {1} 的拼音...", hanzi))
        SetTimer(notifier, 1000)

        loop {
            whr.Open("POST", url, false)
            whr.Send()
            whr.WaitForResponse()
            page := whr.ResponseText
            html.write(page)

            if (html.getElementsByTagName("b")[0] = "") {
                sleep 500
                continue
            } else {
                pinyin := html.getElementsByTagName("b")[0].textContent
                SetTimer(notifier, 0)
                TrayTip("已完成")
                break
            }
        }
        
        unToned := ""

        for tonedChar, char in Dict.tone {
            if (InStr(pinyin, tonedChar)) {
                unToned := StrReplace(pinyin, tonedChar, char)
            }
        }

        html.write("")
        html := ""
        whr := ""

        ; update pinyin dictionary
        SetTimer(() => (
            Dict.pinyin[unToned] := Dict.pinyin[unToned] . hanzi,
            FileDelete(Dict.DICT_PATH . "\pinyin.json"),
            FileAppend(
                JSON.stringify(Dict.pinyin), 
                Dict.DICT_PATH . "\pinyin.json" ,
                "UTF-8"
            )
        ), -1)

        return unToned
    }

    /**
     * Convert the pinyin of last name and first name.
     * @param {string} fullname The name to convert.
     * @returns {array} [last name, first name]
     */
    static getFullnamePinyin(fullname) {
        if (Dict.doubleLastName.Has(SubStr(fullname, 1, 2))) {
            lastname := Dict.doubleLastName[SubStr(fullname, 1, 2)]
            lastnameLength := 2
        } else {
            lastname := this.getPinyin(SubStr(fullname, 1, 1))
            lastnameLength := 1
        }

        firstnameSplit := StrSplit(SubStr(fullname, lastnameLength + 1), "")
        firstname := ""
        loop firstnameSplit.Length {
            firstname .= this.getPinyin(firstnameSplit[A_Index]) . " "
        }

        return [lastname, Trim(firstname)]
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