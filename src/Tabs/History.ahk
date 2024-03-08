; History(CF, config) {
History(CF) {
	; clipHistory := signal(configRead(CONFIG_FILE)["clipHistory"])
	clipHistory := signal(config.read("clipHistory"))
	fillBlank(clipHistory.value)

	OnClipboardChange (*) => (
		saveHistory(),
		sleep(100),
		updateHistoryList()
	)

	saveHistory(*) {
		if (A_Clipboard = "") {
        	return
    	}
    	; if (config["clipHistory"].Length = 10) {
    		; config["clipHistory"].Pop()
    	; }
		updated := []
		if (config.read("clipHistory").Length = 10) {
			updated := config.read("clipHistory").Pop()
		}
    	; config["clipHistory"].InsertAt(1, A_Clipboard)
    	; configSave(CONFIG_FILE, config)
		updated.InsertAt(1, A_Clipboard)
		config.write("clipHistory", updated)
	}

	fillBlank(history){
		filled := history
		if (filled.Length < 10) {
			loop (10 - filled.Length) {
				filled.Push(" ")
			}
		}
		clipHistory.set(filled)
	}

	updateHistoryList(*){
		; updatedHistory := configRead(CONFIG_FILE)["clipHistory"]
		updatedHistory := config.read("clipHistory")
		fillBlank(updatedHistory)
	}

	return (
		clipHistory.value.map(item =>
			AddReactiveEdit(CF, "x30 h38 w250 y+10 ReadOnly", "{1}", clipHistory, A_Index)
		)
	)
}

