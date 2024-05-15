#Include "./JSON.ahk"

class useFileDB {
	__New(dbSetting) {
		this.main := dbSetting.main
		this.backup := dbSetting.HasOwnProp("backup") ? dbSetting.backup : ""
		this.cleanPeriod := dbSetting.HasOwnProp("cleanPeriod") ? dbSetting.cleanPeriod : 0
		this.using := dbSetting.main
	}

	useMain() {
		this.using := this.main
	}

	useBackup() {
		this.using := this.backup
	}

	add(jsonString) {
		dateFolder := "\" . FormatTime(A_Now, "yyyyMMdd")
		fileName := "\" . JSON.parse(jsonString)["fileName"] . ".json"
		; create dateFolder if not exist yet
		if (!DirExist(this.using . dateFolder)) {
			DirCreate(this.using . dateFolder)
		}
		FileAppend(jsonString, this.using . dateFolder . fileName, "UTF-8")
		Sleep 100
		; cleanup outdated if cleanPeriod is unset/0
		if (this.cleanPeriod > 0) {
			this.cleanup()
		}
	}

	findByPeriod(db, queryDate, queryPeriodInput) {
		matchFilePaths := []
		loop files, (db . "\" . queryDate . "\*.json") {
			if (DateDiff(A_Now, A_LoopFileTimeCreated, "Minutes") <= queryPeriodInput) {
				matchFilePaths.InsertAt(1, A_LoopFileFullPath)
			}
		}
		return matchFilePaths
	}

	cleanup() {
		loop files, this.using . "\*", "D" {
			if (DateDiff(A_Now, A_LoopFileName, "Days") > this.cleanPeriod) {
				DirDelete(A_LoopFileFullPath, true)
			}
		}
	}

	load(db := this.using, queryDate := FormatTime(A_Now, "yyyyMMdd"), queryPeriodInput := 60) {
		loadedData := this.findByPeriod(db, queryDate, queryPeriodInput)
			.map(file => JSON.parse(FileRead(file, "UTF-8")))

		return loadedData
	}

	update(fileName, queryDate, newJsonString){
		loop files, (this.using . "\" . queryDate . "\*.json") {
			if (fileName . ".json" = A_LoopFileName) {
				FileDelete(A_LoopFileFullPath)
				FileAppend(newJsonString, this.using . "\" . queryDate . "\" . filename . ".json" , "UTF-8")
			}
		}
	}
}