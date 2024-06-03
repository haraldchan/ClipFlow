defineMapMethods(_map) {
    _map.Prototype.keys := keys
    _map.Prototype.values := values
    _map.Prototype.deepClone := deepClone

    keys(_map) {
        newArray := []

        for k, v in _map {
            newArray.Push(k)
        }

        return newArray
    }

    values(_map) {
        newArray := []

        for k, v in _map {
            newArray.Push(v)
        }

        return newArray
    }

    deepClone(_map) {
        newMap := Map()

        for k, v in _map {
            newMap[k] := v
        }

        return newMap
    }

}

defineMapMethods(Map)