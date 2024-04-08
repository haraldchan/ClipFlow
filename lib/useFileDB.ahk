#Include "./JSON.ahk"

class useFileDB {
	__New(centralPath, localPath := 0) {
		this.centralPath := centralPath
		this.localPath := localPath
		this.using := this.centralPath
	}

	useCentral() {
		this.using := this.centralPath
	}

	useLocal() {
		this.using := this.localPath
	}

	add(jsonString) {
		dateFolder := "\" . FormatTime(A_Now, "yyyyMMdd")
		fileName := "\" . A_Now . A_MSec . ".json"
		FileAppend(jsonString, this.centralPath . dateFolder . fileName)
		Sleep 100
		if (this.localPath != 0) {
			FileAppend(jsonString, this.localPath . dateFolder . fileName)
		}
	}

	findByPeriod(db, queryDate, queryMinPeriod) {
		matchFilePaths := []
		loop files, (db . "\" . queryDate . "\*.json") {
			if (DateDiff(A_Now, A_LoopFileTimeCreated, "Minutes") <= queryMinPeriod) {
				matchFilePaths.Push(A_LoopFileFullPath)
			}
		}
		return matchFilePaths
	}

	load(db := this.using, queryDate := FormatTime(A_Now, "yyyyMMdd"), queryMinPeriod := 60) {

		loadedData := this.findByPeriod(db, queryDate, queryMinPeriod).map(file => JSON.parse(FileRead(file)))

		return loadedData
	}
}