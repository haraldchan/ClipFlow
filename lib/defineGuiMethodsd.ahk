defineGuiMethods(guiProto) {
    guiProto.Prototype.getCtrlByName := getCtrlByName
    guiProto.Prototype.getCtrlByType := getCtrlByType
    guiProto.Prototype.getCtrlByTypeAll := getCtrlByTypeAll

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

}

defineGuiMethods(Gui)