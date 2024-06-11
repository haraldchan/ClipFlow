#Include "../JSON.ahk"
#Include "../defineArrayMethods.ahk"
#Include "./TypeChecker.ahk"
#Include "./AddReactive-Ctrls.ahk"

class signal {
    /**
     * Creates a reactive signal variable.
     * @param {any} initialValue The initial value of the signal.This argument is ignored after the initial render.
     * @return {Signal}
     */
    __New(initialValue) {
        this.value := ((initialValue is Class) or (initialValue is Func))
            ? initialValue
            : initialValue is Object
                ? this.mapify(initialValue)
                : initialValue
        this.subs := []
        this.comps := []
        this.effects := []
    }

    get(mutateFunction := 0) {
        if (mutateFunction != 0 && mutateFunction is Func) {
            return mutateFunction(this.value)
        } else {
            return this.value
        }
    }

    /**
     * Set the new value of the signal.
     * @param {any} newSignalValue New state of the signal. Also accept function object.
     * @returns {void} 
     */
    set(newSignalValue) {
        prevValue := this.value

        if (newSignalValue = this.value) {
            return
        }

        this.value := newSignalValue is Func
            ? newSignalValue(this.value)
            : newSignalValue

        ; change to Map()
        if (!(newSignalValue is Class) && newSignalValue is Object) {
            this.value := this.mapify(this.value)
        }

        ; notify all subscribers to update
        for ctrl in this.subs {
            ctrl.update()
        }

        ; notify all computed signals
        for comp in this.comps {
            comp.sync(this.value)
        }

        ; run all effects
        for effect in this.effects {
            if (effect.MaxParams = 1) {
                effect(this.value)
            } else if (effect.MaxParams = 2) {
                effect(this.value, prevValue)
            } else {
                effect()
            }
        }
    }

    addSub(controlInstance) {
        this.subs.Push(controlInstance)
    }

    addComp(computed) {
        this.comps.Push(computed)
    }

    addEffect(effectFn) {
        this.effects.Push(effectFn)
    }

    mapify(obj) {
        if (!(obj is Object)) {
            return obj
        }
        return JSON.parse(JSON.stringify(obj))
    }
}

class computed {
    /**
     * Create a computed signal which derives a reactive value.
     * @param {signal} depend The signal derives from.
     * @param {Func} computation computation function expression.
     * @return {Signal}
     */
    __New(depend, computation) {
        checkType(depend, signal, "First parameter is not a ReactiveSignal.")
        checkType(computation, Func, "Second parameter is not a Function.")

        this.signal := depend
        this.mutation := computation
        this.value := this.mutation.Call(this.signal.value)
        this.subs := []
        this.comps := []
        this.effects := []

        this.signal.addComp(this)
    }

    sync(newVal) {
        this.value := this.mutation.Call(newVal)

        ; notify all subscribers to update
        for ctrl in this.subs {
            ctrl.update()
        }

        ; notify all computed signals
        for comp in this.comps {
            comp.sync(this.value)
        }

        ; run all effectss
        if (this.effects.Length > 0) {
            for effect in this.effects {
                effect()
            }
        }

    }

    addSub(controlInstance) {
        this.subs.Push(controlInstance)
    }

    addComp(computed) {
        this.comps.Push(computed)
    }

    addEffect(effectFn) {
        this.effects.Push(effectFn)
    }
}

class effect {
    /**
     * Create a effect that runs when the value of depend signal changes.
     * @param {signal} depend The signal associated with.
     * @param {(new?, prev?) => void} effectFn Callback function object. 
     * First param retrieves the new value of the signal, second param retrives previous value.
     * @example effect(signal, (new, prev) => MsgBox(Format("New: {1}, prev: {2}", new, prev)))
     */
    __New(depend, effectFn) {
        depend.addEffect(effectFn)
    }
}

class AddReactive {
    /**
     * Creates a new reactive control and add it to the window.
     * @param {Gui} GuiObject The target Gui Object.
     * @param {string} controlType Control type to create. Available: Text, Edit, CheckBox, Radio, DropDownList, ComboBox, ListView.
     * @param {string} options Options apply to the control, same as Gui.Add.
     * @param {string|Array|Object} content Text or formatted text for text, options for DDL/ComboBox, column option object for ListView.
     * @param {signal|Array|Object} depend Subscribed signal, or an array of signals. 
     * @param {string|number} key A key or index as render indicator.
     * @param {[ event: Event, callback: ()=>void ]} event Events and callback function objects.
     * @returns {AddReactive} 
     */
    __New(GuiObject, controlType, options := "", content := "", depend := 0, key := 0, event := 0) {
        ; params type checking
        checkType(GuiObject, Gui, "Second(GuiObject) param is not a Gui Object.")
        if (controlType != "ListView") {
            checkType(options, String, "First(options) param is not a String.")
        }
        checkTypeDepend(depend)
        ; checkTypeEvent(event)

        this.ctrlType := controlType
        this.GuiObject := GuiObject
        this.depend := depend
        this.key := key
        this.options := options

        if (controlType = "ListView") {
            this.lvOptions := options.lvOptions
            this.itemOptions := options.itemOptions
        }

        if (controlType = "ComboBox" ||
            controlType = "DropDownList") {
                this.innerText := content
        } else if (controlType = "ListView") {
            this.innerText := content.titles
            this.titleKeys := content.keys
            this.colWidths := content.HasOwnProp("widths")
                ? content.widths
                : this.titleKeys.map(item => "AutoHdr")
        } else {
            this.innerText := RegExMatch(content, "\{\d+\}")
                ? this.handleFormatStr(content, depend, key)
                : content
        }


        ; add control
        if (controlType = "ListView") {
            this.ctrl := this.GuiObject.Add(this.ctrlType, this.lvOptions, this.innerText)
            this.handleListViewUpdate()
            for width in this.colWidths {
                this.ctrl.ModifyCol(A_Index, width)
            }
        } else {
            this.ctrl := this.GuiObject.Add(this.ctrlType, this.options, this.innerText)
        }

        ; add subscribe
        if (depend = 0) {
            return
        } else if (depend is Array) {
            for dep in depend {
                dep.addSub(this)
            }
        } else {
            depend.addSub(this)
        }

        ; add event
        if (event != 0) {
            if (event.every(item => item is Array)) {
                ; multiple events
                for e in event {
                    this.ctrl.OnEvent(e[1], e[2])
                }
            } else {
                ; single event
                this.ctrl.OnEvent(event[1], event[2])
            }
        }
    }

    handleFormatStr(formatStr, depend, key) {
        vals := []

        if (key = 0) {
            handleKeyless()
        } else if (key is Number) {
            handleKeyNumber()
        } else {
            handleKeyObject()
        }

        handleKeyless() {
            if (depend is Array) {
                for dep in depend {
                    vals.Push(dep.value)
                }
            } else if (depend.value is Array) {
                vals := depend.value
            } else {
                vals.Push(depend.value)
            }
        }

        handleKeyNumber() {
            for item in depend.value {
                vals.Push(depend.value[key])
            }
        }

        handleKeyObject() {
            if (key[1] is Array) {
                for k in key {
                    if (A_Index = 1) {
                        continue
                    }
                    vals.Push(depend.value[key[1][1]][k])
                }
            } else {
                for k in key {
                    vals.Push(depend.value[k])
                }
            }
        }

        return Format(formatStr, vals*)
    }

    handleListViewUpdate() {
        this.ctrl.Delete()
        for item in this.depend.value {
            itemIn := item
            rowData := this.titleKeys.map(key => itemIn[key])
            this.ctrl.Add(this.itemOptions, rowData*)
        }
        this.ctrl.Modify(1, "Select")
        this.ctrl.Focus()
    }

    update() {
        if (this.ctrl is Gui.Text || this.ctrl is Gui.Button) {
            ; update text label
            this.ctrl.Text := this.handleFormatStr(this.formattedString, this.depend, this.key)
        } else if (this.ctrl is Gui.Edit) {
            ; update text value
            this.ctrl.Value := this.handleFormatStr(this.formattedString, this.depend, this.key)
        } else if (this.ctrl is Gui.ListView) {
            ; update list items
            this.handleListViewUpdate()
        }
    }

    ; control option methods
    setOptions(newOptions) {
        this.ctrl.Opt(newOptions)
    }

    getValue() {
        return this.ctrl.Value
    }

    setValue(newValue) {
        this.ctrl.Value := newValue is Func
            ? newValue(this.ctrl.Value)
            : newValue
    }

    getInnerText() {
        return this.ctrl.Text
    }

    setInnerText(newInnerText) {
        this.ctrl.Text := newInnerText is Func
            ? newInnerText(this.ctrl.Text)
            : newInnerText
    }

    setDepend(depend) {
        this.depend := depend
        this.subscribe(this.depend)
    }

    setEvent(event, callback) {
        this.ctrl.OnEvent(event, callback)
    }

    disable(state) {
        this.ctrl.Enabled := state
    }
}

class IndexList {
    /**
     * Creates a list of multiple reactive controls, ordered by index.
     * @param {Gui} GuiObject The target Gui Object.
     * @param {string} controlType Control type to create. Available: Text, Edit, CheckBox, Radio.
     * @param {string} options Options apply to the control, same as Gui.Add.
     * @param {string} innerText Text or formatted text to hold signal values.
     * @param {signal} depend Subscribed signal
     * @param {[ event: Event, callback: ()=>void ]} event Events and callback function objects.
     * @return {Gui.Control[]}
     */
    __New(GuiObject, controlType, options, innerText, depend := 0, event := 0) {
        indexList := []
        loop depend.value.length {
            indexList.Push(
                GuiObject.AddReactive(controlType, options, innerText, depend, A_Index, event)
            )
        }
    }
}
class KeyList {
    /**
     * Creates a list of multiple reactive controls, render each item by keys.
     * @param {Gui} GuiObject The target Gui Object.
     * @param {string} controlType Control type to create. Available: Text, Edit, CheckBox, Radio.
     * @param {string} options Options apply to the control, same as Gui.Add.
     * @param {string} innerText Text or formatted text to hold signal values.
     * @param {signal} depend Subscribed signal
     * @param {array} key the keys of the signal's value
     * @param {[ event: Event, callback: ()=>void ]} event Events and callback function objects.
     * @return {Gui.Control[]}
     */
    __New(GuiObject, controlType, options, innerText, depend := 0, key := 0, event := 0) {
        keyList := []
        loop depend.value.length {
            keyList.Push(
                GuiObject.AddReactive(controlType, options, innerText, depend, [[A_Index], key*], event)
            )
        }
    }
}

Gui.Prototype.AddReactive := AddReactive
Gui.Prototype.IndexList := IndexList
Gui.Prototype.KeyList := KeyList

; for lsp {
; revue.ahk
; /**
;  *
;  */
; AddReactive(controlType[, options, textString, depend, key, event]) => Gui.Control

; /**
;  *
;  */
; AddReactiveText([options, textString, depend, key, event]) => Gui.Text

; /**
;  *
;  */
; AddReactiveEdit([options, textString, depend, key, event]) => Gui.Edit

; /**
;  *
;  */
; AddReactiveButton([options, textString, depend, key, event]) => Gui.Button

; /**
;  *
;  */
; AddReactiveCheckBox([options, textString, depend, key, event]) => Gui.CheckBox

; /**
;  *
;  */
; AddReactiveRadio([options, textString, depend, key, event]) => Gui.Radio

; /**
;  *
;  */
; AddReactiveDropDownList([options, mapObject, depend, key, event]) => Gui.DDL

; /**
;  *
;  */
; AddReactiveComboBox([options, mapObject, depend, key, event]) => Gui.ComboBox
; }
