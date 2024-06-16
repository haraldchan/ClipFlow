class AddReactiveText extends AddReactive {
    /**
     * Add a reactive Text control to Gui
     * @param {Gui} GuiObject The target Gui Object.
     * @param {string} options Options apply to the control, same as Gui.Add.
     * @param {string} innerText Text or formatted text to hold signal values.
     * @param {signal} [depend] Subscribed signal
     * @param {array} [key] the keys or index of the signal's value
     * @param {[ event: Event, callback: ()=>void ]} [event] Events and callback function objects.
     * @returns {AddReactiveText}     
     */
    __New(GuiObject, options := "", innerText := "", depend := 0, key := 0, event := 0) {
        this.key := key
        super.__New(GuiObject, "Text", options, innerText, depend, key, event)
    }
}

class AddReactiveEdit extends AddReactive {
    /**
     * Add a reactive Edit control to Gui
     * @param {Gui} GuiObject The target Gui Object.
     * @param {string} options Options apply to the control, same as Gui.Add.
     * @param {string} innerText Text or formatted text to hold signal values.
     * @param {signal} [depend] Subscribed signal
     * @param {array} [key] the keys or index of the signal's value
     * @param {[ event: Event, callback: ()=>void ]} [event] Events and callback function objects.
     * @returns {AddReactiveEdit}     
     */
    __New(GuiObject, options := "", innerText := "", depend := 0, key := 0, event := 0) {
        this.key := key
        super.__New(GuiObject, "Edit", options, innerText, depend, key, event)
    }
}

class AddReactiveButton extends AddReactive {
    /**
     * Add a reactive Button control to Gui
     * @param {Gui} GuiObject The target Gui Object.
     * @param {string} options Options apply to the control, same as Gui.Add.
     * @param {string} innerText Text or formatted text to hold signal values.
     * @param {signal} [depend] Subscribed signal
     * @param {array} [key] the keys or index of the signal's value
     * @param {[ event: Event, callback: ()=>void ]} [event] Events and callback function objects.
     * @returns {AddReactiveButton}     
     */
    __New(GuiObject, options := "", innerText := "", depend := 0, key := 0, event := 0) {
        this.key := key
        super.__New(GuiObject, "Button", options, innerText, depend, key, event)
    }
}

class AddReactiveCheckBox extends AddReactive {
    /**
     * Add a reactive CheckBox control to Gui
     * @param {Gui} GuiObject The target Gui Object.
     * @param {string} options Options apply to the control, same as Gui.Add.
     * @param {string} innerText Text or formatted text to hold signal values.
     * @param {signal} [depend] Subscribed signal
     * @param {array} [key] the keys or index of the signal's value
     * @param {[ event: Event, callback: ()=>void ]} [event] Events and callback function objects.
     * @returns {AddReactiveCheckBox}     
     */
    __New(GuiObject, options := "", innerText := "", depend := 0, key := 0, event := 0) {
        this.key := key
        super.__New(GuiObject, "CheckBox", options, innerText, depend, key, event)
    }
}

class AddReactiveRadio extends AddReactive {
    /**
     * Add a reactive Radio control to Gui
     * @param {Gui} GuiObject The target Gui Object.
     * @param {string} options Options apply to the control, same as Gui.Add.
     * @param {string} innerText Text or formatted text to hold signal values.
     * @param {signal} [depend] Subscribed signal
     * @param {array} [key] the keys or index of the signal's value
     * @param {[ event: Event, callback: ()=>void ]} [event] Events and callback function objects.
     * @returns {AddReactiveRadio}     
     */
    __New(GuiObject, options := "", innerText := "", depend := 0, key := 0, event := 0) {
        this.key := key
        super.__New(GuiObject, "Radio", options, innerText, depend, key, event)
    }
}

class AddReactiveDropDownList extends AddReactive {
    __New(GuiObject, options, mapObj, depend := 0, key := 0, event := 0) {
        ; mapObj: a Map(value, optionText) map object
        this.key := key
        this.mapObj := mapObj
        this.vals := []
        this.text := []
        for val, text in this.mapObj {
            this.vals.Push(val)
            this.text.Push(text)
        }
        super.__New(GuiObject, "DropDownList", options, this.text, depend, key, event)
    }

    ; overiding the getValue() of ReactiveControl. Returning the value of mapObj instead.
    getValue() {
        return this.vals[this.ctrl.Value]
    }
}

class AddReactiveComboBox extends AddReactive {
    __New(GuiObject, options, mapObj, depend := 0, key := 0, event := 0) {
        ; mapObj: a Map(value, optionText) map object
        this.key := key
        this.mapObj := mapObj
        this.vals := []
        this.text := []
        for val, text in this.mapObj {
            this.vals.Push(val)
            this.text.Push(text)
        }
        super.__New(GuiObject, "ComboBox", options, this.text, depend, key, event)
    }

    getValue() {
        return this.vals[this.ctrl.Value]
    }
}

class AddReactiveListView extends AddReactive {
    ; options of ListView: { lvOptions:"", itemOptions:"" }
    ; colTitleMap indicates the relationship between column titles and the actual key of depend obj.

    /**
     * Add a reactive ListView control to Gui
     * @param {Gui} GuiObject The target Gui Object.
     * @param {string} options Options apply to the control, same as Gui.Add.
     * @param {{keys: string[], titles: string[], width: number[]}} columnDetails Descriptor object contains keys of col value, column title texts and column width.
     * @param {signal} depend Subscribed signal
     * @param {array} [key] the keys or index of the signal's value
     * @param {[ event: Event, callback: ()=>void ]} [event] Events and callback function objects.
     * @returns {AddReactiveListView}     
     */
    __New(GuiObject, options, columnDetails, depend := 0, key := 0, event := 0) {
        this.key := key
        super.__New(GuiObject, "ListView", options, columnDetails, depend, key, event)
    }
}

class AddReactiveDateTime extends AddReactive {
    /**
     * Add a reactive ListView control to Gui
     * @param {Gui} GuiObject The target Gui Object.
     * @param {string} options Options apply to the control, same as Gui.Add.
     * @param {signal} depend Subscribed signal
     * @param {[ event: Event, callback: ()=>void ]} [event] Events and callback function objects.
     * @returns {AddReactiveDateTime}     
     */
    __New(GuiObject, options, depend := 0, event := 0) {
        super.__New(GuiObject, "DateTime", options,, depend,, event)
    }
}

class AddReactiveMonthCal extends AddReactive {
    /**
     * Add a reactive ListView control to Gui
     * @param {Gui} GuiObject The target Gui Object.
     * @param {string} options Options apply to the control, same as Gui.Add.
     * @param {signal} depend Subscribed signal
     * @param {[ event: Event, callback: ()=>void ]} [event] Events and callback function objects.
     * @returns {AddReactiveMonthCal}     
     */
    __New(GuiObject, options, depend := 0, event := 0) {
        super.__New(GuiObject, "MonthCal", options,, depend,, event)
    }
}

; mount to Gui.Prototype
Gui.Prototype.AddReactiveText := AddReactiveText
Gui.Prototype.AddReactiveEdit := AddReactiveEdit
Gui.Prototype.AddReactiveButton := AddReactiveButton
Gui.Prototype.AddReactiveCheckBox := AddReactiveCheckBox
Gui.Prototype.AddReactiveRadio := AddReactiveRadio
Gui.Prototype.AddReactiveComboBox := AddReactiveComboBox
Gui.Prototype.AddReactiveDropDownList := AddReactiveDropDownList
Gui.Prototype.AddReactiveListView := AddReactiveListView
Gui.Prototype.AddReactiveDateTime := AddReactiveDateTime
Gui.Prototype.AddReactiveMonthCal := AddReactiveMonthCal