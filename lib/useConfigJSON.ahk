class useConfigJSON {
    __New(configTemplate, configFileName) {
        this.configTemplate := configTemplate
        this.configFilename := configFilename
        this.path := this.createLocal()
    }

    createLocal() {
        if (!FileExist(A_MyDocuments . "\" . this.configFileName)) {
            FileCopy(this.configTemplate, A_MyDocuments)
        }
        return A_MyDocuments . "\" . this.configFileName
    }

    read(key) {
        getValue(obj, key) {
            if (obj is Object && !(obj is Array) && !(obj is Map)) {
                for k, v in obj {
                    if (k == key) {
                        return v
                    }
                    if (obj.HasOwnProp(k)) {
                        return getValue(v, key)
                    }
                }
            }
        }

        config := JSON.parse(FileRead(this.path))
        return getValue(config, key)
    }

    write(key, val) {
        writeValue(obj, key, val) {
            if (obj is Object && !(obj is Array) && !(obj is Map)) {
                for k in obj {
                    if (k == key) {
                        v := val
                    }
                    if (obj.HasOwnProp(k)) {
                        writeValue(v, key, val)
                    }
                }
            }
        }

        config := JSON.parse(FileRead(this.path))
        writeValue(config, key, val)
        
        FileDelete(this.path)
        FileAppend(JSON.stringify(config), this.path)
    }
}