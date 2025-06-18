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
    static provincesById := JSON.parse(FileRead(this.DICT_PATH . "\province-by-id.json", "UTF-8"))

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
            if (hanCharacters.includes(hanzi)) {
                return !useWG ? pinyin : Dict.pinyinWade[pinyin]
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

        whr.Open("POST", url, false)
        whr.Send()
        whr.WaitForResponse()
        page := whr.ResponseText
        Sleep 500
        toned := page.split('<span class="pinyin">')[2].split("</span>")[1].replace("[", "").replace("]", "").trim()

        for tonedChar, char in Dict.tone {
            if (toned.includes(tonedChar)) {
                unToned := toned.replace(tonedChar, char).trim()
            }
        }

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
        if (Dict.doubleLastName.Has(fullname.substr(1, 2))) {
            lastname := Dict.doubleLastName[fullname.substr(1, 2)]
            if (useWG == true) {
                lastname := lastname.split(" ").map(pinyin => Dict.pinyinWade[pinyin]).join("-")
            }
            lastnameLength := 2
        } else {
            lastname := this.getPinyin(fullname.substr(1, 1), useWG)
            lastnameLength := 1
        }

        firstName := fullname.substr(lastnameLength + 1)
                             .split("")
                             .map(hanzi => this.getPinyin(hanzi, useWG))
                             .join(useWG == false ? " " : "-")

        return [lastname.trim(), firstname.trim()]
    }

    /**
     * Get the ISO 3166-1 alpha-2 regional code.
     * @param {string} country The chinese country name to convert.
     * @returns {any} 
     */
    static getCountryCode(country) {
        ; for region, code in Dict.regionISO {
        ;     if (country == region) {
        ;         return code
        ;     }
        ; }
        return Dict.regionISO[country]
    }

    /**
     * Get the province name by address
     * @param {string} address 
     * @returns {any} 
     */
    static getProvince(address) {

        for province, code in Dict.provinces {
            if (address.include(province)) {
                if (code != "") {
                    return code
                }
            }
        }

        for code, cities in Dict.provinceWithCities {
            for city in cities {
                if (address.includes(city)) {
                    return code
                }
            }
        }
    }

    static getProvinceById(idNum) {
        return Dict.provincesById[idNum.substr(1, 2)]
    }

    static getIdTypeCode(idType) {
        for type, code in Dict.idTypes {
            if (type = idType) {
                return code
            }
        }
    }
}