#Include "./JSON.ahk"

class useFileDB {
	__New(centralPath, localPath := 0){
		this.centralPath := centralPath
		this.localPath := localPath
	}

	add(jsonObject){
		dateFolder := "\" . FormatTime(A_Now, "yyyyMMdd")
		fileName := "\" . A_Now . A_MSec . ".json"
		FileAppend(JSON.stringify(jsonObject), this.centralPath . dateFolder . fileName)
		Sleep 100
		if (this.localPath != 0) {
			FileAppend(JSON.stringify(jsonObject), this.localPath . dateFolder . fileName)
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

	load(db := this.centralPath, queryDate := FormatTime(A_Now, "yyyyMMdd"), queryMinPeriod := 60){

		loadedData := this.findByPeriod(db, queryDate, queryMinPeriod).map(file => JSON.parse(FileRead(file)))

		return loadedData
	}
}