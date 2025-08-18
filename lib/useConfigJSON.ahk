class useConfigJSON {
    __New(configTemplateSrc, configFileName, configDest := A_MyDocuments) {
        this.configTemplateSrc := configTemplateSrc
        this.configFilename := configFilename
        this.configDest := configDest
        this.path := this.createLocal()
        this.currentConfig := JSON.parse(FileRead(this.path))
    }

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

    /**
     * Reads value from config json.
     * @param {String|Array} key
     * @returns {Any}
     */
    read(key) {
        if (!(key is String) && !(key is Array)) {
            throw TypeError("Key is not a String or Array", -1, key)
        }

        if (key is String) {
            return this._readFirstMatch(key, this.currentConfig)
        }

        if (key is Array) {
            return this._readExactMatch(key, this.currentConfig)
        }
    }

    _readFirstMatch(key, config) {
        if (config.Has(key)) {
            result := config[key]
            return IsObject(result) ? JSON.parse(JSON.stringify(result)) : result 
        }

        for k, v in config {
            if (v is Map) {
                res := this._readFirstMatch(key, v)
                if (res) {
                    return res
                }
            }
        }
    }

    _readExactMatch(keys, config, index := 1) {
        if (index == keys.Length) {
            result := config[keys[index]]
            return IsObject(result) ? JSON.parse(JSON.stringify(result)) : result 
        }

        return this._readExactMatch(keys, config[keys[index]], index + 1)
    }

    /**
     * Writes new value to specific key in config json
     * @param {String|Array} key 
     * @param {Any} newValue  
     */
    write(key, newValue) {
        if (!(key is String) && !(key is Array)) {
            throw TypeError("Key is not a String or Array")
        }

        if (key is String) {
            this._writeFirstMatch(key, this.currentConfig, newValue)
        }

        if (key is Array) {
            this._writeExactMatch(key, this.currentConfig, newValue)
        }

        FileDelete(this.path)
        FileAppend(JSON.stringify(this.currentConfig), this.path, "UTF-8")
    }

    _writeFirstMatch(key, config, newValue) {
        if (config.Has(key)) {
            config[key] := newValue
            return
        }

        for k, v in config {
            if (v is Map) {
                this._writeFirstMatch(key, v, newValue)
            }
        }
    }

    _writeExactMatch(keys, config, newValue, index := 1) {
        if (index == keys.Length) {
            config[keys[index]] := newValue
            return
        }

        for k, v in config {
            if (k == keys[index]) {
                this._writeExactMatch(keys, v, newValue, index + 1)
            }
        }
    }
}