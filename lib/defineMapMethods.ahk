defineMapMethods(_map) {
    _map.Prototype.keys := keys
    _map.Prototype.values := values
    _map.Prototype.getKey := getKey
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

    getKey(_map, value) {
        for k, v in _map {
            if (v = value) {
                return k
            }
        }
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

class OrderedMap extends Map {
    __New(pairs*) {
        this.pairs := pairs
        this.order := []

        this.Set(pairs)
    }

    __Enum(n) {       
        sup := super              ; n = number of args in FOR loop
        i := 1                      ; the "counter"
        return (n=1) ? enum1 : enum2 ; must return a func that returns TRUE or FALSE
        
        ; enclosure func #1 - with only 1 FOR loop var
        enum1(&key) {
            if (i <= this.order.length) {       ; check limit
                key := this.order[i]   ; set FOR loop var
                i++             ; increment counter
                return true         ; return TRUE to keep iterating
            } else
                return false        ; return FALSE to stop the FOR loop
        }
        
        ; enclosure func #2 - with only 2 FOR loop vars
        enum2(&key, &val) {
            if (i <= sup.Capacity) {       ; check limit
                key := this.order[2 * i - 1]              ; set FOR loop vars
                val := this[key]
                i := i + 2                 ; increment counter
                return true         ; return TRUE to keep iterating
            } else
                return false        ; return FALSE to stop the FOR loop
        }
    }
}