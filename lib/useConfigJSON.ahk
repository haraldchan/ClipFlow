class useConfigJSON {
    __New(configTemplateSrc, configFileName, configDest := A_MyDocuments) {
        this.configTemplateSrc := configTemplateSrc
        this.configFilename := configFilename
        this.configDest := configDest
        this.path := this.createLocal()
    }

    createLocal() {
        if (!FileExist(this.configDest . "\" . this.configFileName)) {
            FileCopy(this.configTemplateSrc, this.configDest)
        }
        return this.configDest . "\" . this.configFileName
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

