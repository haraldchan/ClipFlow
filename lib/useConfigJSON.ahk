class useConfigJSON {
    __New(configTemplateSrc, configFileName, configDest := A_MyDocuments) {
        this.configTemplateSrc := configTemplateSrc
        this.configFilename := configFilename
        this.configDest := configDest
        this.path := this.createLocal()
    }

    _config() => JSON.parse(FileRead(this.path))

    updateKeys() {
        localConfig := JSON.parse(FileRead(this.path, "UTF-8"))
        tempConfig := JSON.parse(FileRead(this.configTemplateSrc, "UTF-8"))

        if (localConfig.Capacity != tempConfig.Capacity) {
            this.path := this.createLocal()
        }
    }

    createLocal() {
        if (!FileExist(this.configDest . "\" . this.configFileName)) {
            FileCopy(this.configTemplateSrc, this.configDest)
        }
        return this.configDest . "\" . this.configFileName
    }

    ; read(key) {
    ;     getValue(obj, key) {
    ;         val := ""

    ;         for k, v in obj {
    ;             if (k = key) {
    ;                 return v
    ;             } else if (v is Object) {
    ;                 val := getValue(v, key)
    ;                 if (val != "") {
    ;                     return val
    ;                 }
    ;             }
    ;         }

    ;         return val
    ;     }

    ;     configRead := JSON.parse(FileRead(this.path))
    ;     return getValue(configRead, key)
    ; }

    /**
     * Reads value from config json.
     * @param {String|Array} key
     * @returns {Any}
     */
    read(key) {
        if (!(key is String) || !(key is Array)) {
            throw TypeError("Key is not a String or Array")
        }

        if (key is String) {
            this._readFirstMatch(key, this._config())
        }

        if (key is Array) {
            this._readExactMatch(key, this._config())
        }
    }

    _readFirstMatch(key, config) {
        if (config.Has(key)) {
            return config[key]
        }

        for k, v in config {
            if (k is Map) {
                res := this._readFirstMatch(key, v)
                if (res) {
                    return res
                }
            }
        }
    }

    _readExactMatch(keys, config, index := 1) {
        if (index == keys.Length) {
            return config[keys[index]]
        }

        return this._readExactMatch(keys, config[keys[index]], index++)
    }

    ; write(keyToFind, newVal) {
    ;     writeValue(obj, key, val) {
    ;         o := obj

    ;         for k, v in o {
    ;             if (k = key) {
    ;                 o[k] := val
    ;                 break
    ;             }
    ;             else if (v is Object) {
    ;                 writeValue(v, key, newVal)
    ;             }
    ;         }

    ;         return o
    ;     }

    ;     config := JSON.parse(FileRead(this.path, "UTF-8"))

    ;     FileDelete(this.path)
    ;     FileAppend(JSON.stringify(writeValue(config, keyToFind, newVal)), this.path, "UTF-8")
    ; }

    /**
     * Writes new value to specific key in config json
     * @param {String|Array} key 
     * @param {Any} newValue  
     */
    write(key, newValue) {
        if (!(key is String) || !(key is Array)) {
            throw TypeError("Key is not a String or Array")
        }

        if (key is String) {
            this._writeFirstMatch(key, this._config(), newValue)
        }

        if (key is Array) {
            this._writeExactMatch(key, this._config, newValue)
        }

        FileDelete(this.path)
        FileAppend(JSON.stringify(this._config()), this.path, "UTF-8")
    }

    _writeFirstMatch(key, config, newValue) {
        if (config.Has(key)) {
            config[key] := newValue
        }

        for k, v in config {
            if (v is Map) {
                return this._writeFirstMatch(key, config, newValue)
            }
        }
    }

    _writeExactMatch(keys, config, newValue, index := 1) {
        if (index == keys.Length) {
            config[keys[index]] := newValue
        }

        return this._writeExactMatch(keys, config[keys[index]], newValue, index++)
    }
}