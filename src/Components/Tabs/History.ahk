History(CF) {
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
		updated := config.read("clipHistory")
		
		for item in updated {
			if (A_Clipboard = item) {
				return
			}
		}

		if (updated.Length = 10) {
			updated.Pop()
		}
		updated.InsertAt(1, A_Clipboard)
		config.write("clipHistory", updated)
	}

	fillBlank(history){
		filled := history
		if (filled.Length < 10) {
			loop (10 - filled.Length) {
				filled.Push("")
			}
		}
		clipHistory.set(filled)
	}

	updateHistoryList(*){
		updatedHistory := config.read("clipHistory")
		fillBlank(updatedHistory)
	}

	return (
		CF.IndexList("Edit", "x30 h40 w250 y+10 ReadOnly", "{1}", clipHistory)
	)
}