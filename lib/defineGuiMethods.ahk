defineGuiMethods(guiProto) {
    guiProto.Prototype.getCtrlByName := getCtrlByName
    guiProto.Prototype.getCtrlByType := getCtrlByType
    guiProto.Prototype.getCtrlByTypeAll := getCtrlByTypeAll
    guiProto.ListView.Prototype.getCheckedRowNumbers := getCheckedRowNumbers

    getCtrlByName(guiProto, vName) {
        for ctrl in guiProto {
            if (ctrl.Name = vName) {
                return ctrl
            }
        }
        throw ValueError("Name not found.")
    }

    getCtrlByType(guiProto, ctrlType) {
        for ctrl in guiProto {
            if (ctrl.Type = ctrlType) {
                return ctrl
            }
        }
        throw TypeError("Control type not found.")
    }

    getCtrlByTypeAll(guiProto, ctrlType) {
        ctrlArray := []

        for ctrl in guiProto {
            if (ctrl.Type = ctrlType) {
                ctrlArray.Push(ctrl)
            }
        } 

        return ctrlArray
    }

    static getCheckedRowNumbers(guiListView, LV) {
        checkedRowNumbers := []
        loop LV.GetCount() {
            curRow := LV.GetNext(A_Index - 1, "Checked")
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
}

defineGuiMethods(Gui)