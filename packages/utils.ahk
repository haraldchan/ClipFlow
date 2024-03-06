#Include "./JSON.ahk"

;utils: general utility methods
class utils {
    ; Reset windows and key states.
    static cleanReload(winGroup, quit := 0) {
        ; Windows set default
        loop winGroup.Length {
            if (WinExist(winGroup[A_Index])) {
                WinSetAlwaysOnTop false, winGroup[A_Index]
            }
        }
        ; Key/Mouse state set default
        BlockInput false
        SetCapsLockState false
        CoordMode "Mouse", "Screen"
        if (quit = "quit") {
            ExitApp
        }
        Reload
    }

    ; Exit app with clean reload.
    static quitApp(appName, popupTitle, winGroup) {
        quitConfirm := MsgBox(Format("是否退出 {1}？", appName), popupTitle, "OKCancel 4096")
        quitConfirm = "OK" ? this.cleanReload(winGroup, "quit") : this.cleanReload(winGroup)
    }

    ; Insert text at the beginning of file.
    static filePrepend(textToInsert, fileToPrepend) {
        textOrigin := FileRead(fileToPrepend)
        FileDelete fileToPrepend
        FileAppend textToInsert . textOrigin, fileToPrepend
    }

    ; Type checking with error msg.
    static checkType(val, typeChecking, errMsg) {
        if (!(val is typeChecking)) {
            throw TypeError(Format("{1}; `n`nCurrent Type: {2}", errMsg, Type(val)))
        }
    }
}

;debug: save output log / show msgbox
class debug {
    static mb(obj) {
        str := JSON.stringify(obj)
        MsgBox(str, "Debug")
    }

    static log(res) {
        log := A_MyDocuments . "\" . FormatTime(A_Now, "yyyyMMdd") . "-log.txt" 
        if (!FileExist(log)) {
            FileAppend("", log)
        }
        sendPrefix := Format("From: {1}, {2} `r`n", A_UserName, FormatTime(A_Now))
        logText := JSON.stringify(res)
        utils.filePrepend(sendPrefix . logText . "`r`n`r`n", log)
    }
}

; interface: methods to interact with GUI controls.
class interface {

    static getCheckedRowNumbers(listViewCtrl) {
        if (!(listViewCtrl is Gui.Control) || listViewCtrl.Type != "ListView") {
            throw TypeError("Parameter is not an ListView.")
        }

        checkedRowNumbers := []
        loop listViewCtrl.GetCount() {
            curRow := listViewCtrl.GetNext(A_Index - 1, "Checked")
            try {
                if (curRow = prevRow || curRow = 0) {
                    Continue
                }
            }
            checkedRowNumbers.Push(curRow)
            prevRow := curRow
        }
        return checkedRowNumbers
    }

    static getCheckedRowDataMap(listViewCtrl, mapKeys, checkedRows) {
        if (!(listViewCtrl is Gui.Control) || listViewCtrl.Type != "ListView") {
            throw TypeError("Parameter is not an ListView.")
        }
        utils.checkType(mapKeys, Array, "Second parameter is not an Array")
        utils.checkType(checkedRows, Array, "Third parameter is not an Array")

        checkedRowsData := []
        for rowNumber in checkedRows {
            dataMap := Map()
            for key in mapKeys {
                dataMap[key] := listViewCtrl.GetText(rowNumber, A_Index)
            }
            checkedRowsData.Push(dataMap)
        }
        return checkedRowsData
    }
}