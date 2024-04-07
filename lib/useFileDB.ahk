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

	findByPeriod(queryPeriod) {
		matchFilePaths := []
		loop files, (db . "\" . queryDate . "\*.json") {
			if (DateDiff(A_Now, A_LoopFileTimeCreated, "Minutes") <= queryPeriod) {
				matchFilePaths.Push(A_LoopFileFullPath)
			}
		} 	
		return matchFilePaths
	}

	load(queryDate := FormatTime(A_Now, "yyyyMMdd"), period := 60 , db := this.centralPath){
		this.findByPeriod(period)

		loadedData := this.findByPeriod(period).map(file => JSON.parse(FileRead(file)))

		return loadedData
	}
}