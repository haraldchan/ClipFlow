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
		fileName := "\" . A_Now . A_MSec . ".json"
		; create dateFolder if not exist yet
		if (!DirExist(this.using . dateFolder)) {
			DirCreate(this.using . dateFolder)
		}
		FileAppend(jsonString, this.using . dateFolder . fileName, "UTF-8")
		Sleep 100
		; cleanup outdated if cleanPeriod is unset/0
		if (this.cleanPeriod > 0) {
			this.cleanup(this.cleanPeriod)
		}
	}

	findByPeriod(db, queryDate, queryPeriodInput) {
		matchFilePaths := []
		loop files, (db . "\" . queryDate . "\*.json") {
			if (DateDiff(A_Now, A_LoopFileTimeCreated, "Minutes") <= queryPeriodInput) {
				; MsgBox(A_LoopFileFullPath)
				matchFilePaths.unshift(A_LoopFileFullPath)
			}
		}
		return matchFilePaths
	}

	cleanup(db) {
		loop files, db, "D" {
			msgbox(A_LoopFileFullPath)
			if (DateDiff(A_Now, A_LoopFileTimeCreated, "Days") > this.cleanPeriod) {
				DirDelete(A_LoopFileFullPath, true)
			}
		}
	}

	load(db := this.using, queryDate := FormatTime(A_Now, "yyyyMMdd"), queryPeriodInput := 60) {
		loadedData := this.findByPeriod(db, queryDate, queryPeriodInput)
			.map(file => JSON.parse(FileRead(file, "UTF-8")))

		return loadedData
	}
}