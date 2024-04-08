#Include "./DictIndex.ahk"

class PMN_FillIn {
    static parse(currentGuest) {
        parsedInfo := Map()
        ; alt Name
        parsedInfo["nameAlt"] := currentGuest["guestType"] = "国外旅客"
            ? " "
            : currentGuest["name"]
        ; last name
        parsedInfo["nameLast"] := currentGuest["guestType"] = "内地旅客"
            ? getFullnamePinyin(currentGuest["name"])[1]
            : currentGuest["nameLast"]
        ; first name
        parsedInfo["nameFirst"] := currentGuest["guestType"] = "内地旅客"
            ? getFullnamePinyin(currentGuest["name"])[2]
            : currentGuest["nameFirst"]
        ; address
        parsedInfo["address"] := currentGuest["guestType"] = "内地旅客" 
            ? currentGuest["addr"]
            : " "
        ; language
        parsedInfo["language"] := currentGuest["guestType"] = "内地旅客"
            ? "C"
            : "E"
        ; country
        parsedInfo["country"] := currentGuest["guestType"] = "国外旅客"
            ? getCountryCode(currentGuest["country"])
            : "CN"
        ; address
        parsedInfo["address"] := currentGuest["guestType"] = "内地旅客"
            ? currentGuest["addr"]
            : " "
        ; province(mainland)
        parsedInfo["province"] := currentGuest["guestType"] = "内地旅客"
            ? getProvince(currentGuest["address"])
            : " "
        ; id number
        parsedInfo["idNum"] := currentGuest["idNum"]
        ; id Type
        parsedInfo["idType"] := getIdTypeCode(currentGuest["idType"])
        ; gender
        parsedInfo["gender"] := currentGuest["gender"]
        ; birthday
        parsedInfo["birthday"] := currentGuest["birthday"]

        return parsedInfo
    }
}