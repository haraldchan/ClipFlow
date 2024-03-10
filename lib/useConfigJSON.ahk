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
            val := ""

            for k, v in obj {
                if (k = key) {
                    return v
                } else if (v is Object) {
                    val := getValue(v, key)
                    if (val != "") {
                        return val
                    }
                }
            }

            return val
        }

        configRead := JSON.parse(FileRead(this.path))
        return getValue(configRead, key)
    }

    write(keyToFind, newVal) {
        
        writeValue(obj, key, val) {
            o := obj

            for k, v in o {
                if (k = key) {
                    o[k] := val
                    break
                }
                 else if (v is Object) {
                    writeValue(v, key, newVal)
                }
            }

            return o
        }

        config := JSON.parse(FileRead(this.path))
        
        FileDelete(this.path)
        FileAppend(JSON.stringify(writeValue(config, keyToFind, newVal)), this.path)
    }
}