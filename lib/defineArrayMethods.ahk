defineArrayMethods(arr){
    arr.Prototype.Some := some
    arr.Prototype.Every := every
    arr.Prototype.Filter := filter
    arr.Prototype.Map := map
    arr.Prototype.Reduce := reduce
    arr.Prototype.With := with
    arr.Prototype.Concat := concat
    arr.Prototype.Unshift := unshift
    arr.Prototype.toReversed := toReversed

    some(arr, fn){
        for item in arr {
            if (fn(item)) {
                return true
            }
        }
        return false
    }

    every(arr, fn){
        for item in arr {
            if (!fn(item))
            return false
        }
        return true
    }

    filter(arr, fn) {
        newArray := []

        for item in arr {
            if (fn(item)) {
                newArray.Push(item)
            }
        }
        return newArray
    }

    map(arr, fn) {
        newArray := []

        if (fn.MaxParams = 1) {
            for item in arr {
                newArray.Push(fn(item))
            }
        } else if (fn.MaxParams = 2) {
            for item in arr {
                newArray.Push(fn(item, A_Index))
            }
        }

        return newArray
    }
    
    reduce(arr, fn, initialValue) {
        initIsSet := !(initialValue = 0)
        accumulator := initIsSet ? initialValue : arr[1]
        currentValue := initIsSet ? arr[1] : arr[2]
        loopTimes := initIsSet ? arr.Length : arr.Length - 1
        result := 0

        loop loopTimes {
            if (A_Index = 1) {
                result := fn(accumulator, currentValue)
            } else {
                if (!(initialValue = 0)) {
                    result := fn(result, arr[A_Index])
                } else {
                    result := fn(result, arr[A_Index + 1])
                }
            }
        }
        return result
    }

    with(arr, index, newValue) {
        if (index > arr.Length) {
            throw ValueError("Index out of range")  
        }

        newArray := []
        for item in arr {
            newArray.Push(item)
        }
        newArray[index] := newValue
        return newArray
    }

    concat(arr, val){
        newArray := arr

        if (val is Array) {
            for item in val {
                newArray.Push(item)
            }
        } else {
            newArray.Push(val)
        }
        return newArray
    }

    unshift(arr, val){
        newArray := arr

        if (val is Array) {

            for item in val.toReversed() {
                newArray.InsertAt(1, item)
            }
        } else {
            newArray.InsertAt(1, val)
        }
        return newArray    
    }

    toReversed(arr){
        newArray := []
        index := arr.Length

        loop arr.Length {
            newArray.Push(arr[index])
            index--
        }

        return newArray
    }
}

defineArrayMethods(Array)