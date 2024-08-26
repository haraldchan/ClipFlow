class useFileDB {
	__New(dbSetting) {
		this.main := dbSetting.main
		this.local := dbSetting.HasOwnProp("local") ? dbSetting.backup : ""
		this.archive := dbSetting.HasOwnProp("archive") ? dbSetting.archive : ""
		this.backup := dbSetting.HasOwnProp("backup") ? dbSetting.backup : ""
		this.cleanPeriod := dbSetting.HasOwnProp("cleanPeriod") ? dbSetting.cleanPeriod : 0
		this.recentLength := dbSetting.HasOwnProp("recentLength") ? dbSetting.recentLength : 1000
		this.IS_BACKINGUP_RECENT := false
	}

	add(jsonString) {
		dateFolder := "\" . FormatTime(A_Now, "yyyyMMdd")
		fileName := "\" . JSON.parse(jsonString)["fileName"] . ".json"
		; create dateFolder if not exist yet
		if (!DirExist(this.main . dateFolder)) {
			DirCreate(this.main . dateFolder)
		}
		if (FileExist(this.main . dateFolder . fileName)) {
			return
		}
		FileAppend(jsonString, this.main . dateFolder . fileName, "UTF-8")
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
		loop files, this.main . "\*", "D" {
			if (DateDiff(A_Now, A_LoopFileName, "Days") > this.cleanPeriod) {
				DirDelete(A_LoopFileFullPath, true)
			}
		}
	}

	load(db := this.main, queryDate := FormatTime(A_Now, "yyyyMMdd"), queryPeriodInput := 60) {
		if (queryDate = FormatTime(A_Now, "yyyyMMdd")) {
			return this.loadOneDay(db, queryDate, queryPeriodInput)
		} else if (FileExist(this.archive . "\" . queryDate . " - archive.json")) {
			return this.loadArchiveOneDay(queryDate)
		} else {
			if (!FileExist(this.archive . "\" . queryDate . " - archive.json")) {
				if (DateDiff(A_Now, queryDate, "Days") > 0) {
					SetTimer(() => this.createArchive(queryDate), -100)
				}
				return this.loadOneDay(db, queryDate, 60 * 24 * this.cleanPeriod)
			}
		}
	}

	loadOneDay(db := this.main, queryDate := FormatTime(A_Now, "yyyyMMdd"), queryPeriodInput := 60) {
		loadedData := this.findByPeriod(db, queryDate, queryPeriodInput)
			.map(file => JSON.parse(FileRead(file, "UTF-8")))

		return loadedData
	}

	updateOne(fileName, queryDate, newJsonString) {
		loop files, (this.main . "\" . queryDate . "\*.json") {
			if (fileName . ".json" = A_LoopFileName) {
				FileDelete(A_LoopFileFullPath)
				FileAppend(newJsonString, this.main . "\" . queryDate . "\" . filename . ".json", "UTF-8")
			}
		}

		if (queryDate != FormatTime(A_Now, "yyyyMMdd")) {
			FileDelete(this.archive . "\" . queryDate . " - archive.json")
			this.createArchive(queryDate)
			this.createArchiveBackup(queryDate)
		}
	}

	createArchive(archiveDate) {
		archiveData := JSON.stringify(this.loadOneDay(, archiveDate, 60 * 24 * this.cleanPeriod))
		archiveFullPath := this.archive . "\" . archiveDate . " - archive.json"
		FileAppend(archiveData, archiveFullPath, "UTF-8")
	}

	loadArchiveOneDay(archiveDate) {
		archiveFullPath := this.archive . "\" . archiveDate . " - archive.json"
		archivedData := JSON.parse(FileRead(archiveFullPath, "UTF-8"))
		return archivedData
	}

	createRecentBackup(period := 60) {
		if (this.IS_BACKINGUP_RECENT = true) {
			return
		} else {
			this.IS_BACKINGUP_RECENT := true
		}
		recentBackupFullPath := this.backup . "\recent.json"
		recent := FileExist(recentBackupFullPath) ? JSON.parse(FileRead(recentBackupFullPath, "UTF-8")) : []		
		recent.Push(this.loadOneDay(,, period)*)

		

		if (recent.Length > this.recentLength) {
			recent.RemoveAt( this.recentLength + 1, recent.Length - this.recentLength)
		}

		if (FileExist(recentBackupFullPath)) {
			FileDelete(recentBackupFullPath)
		}

		FileAppend(JSON.stringify(recent), recentBackupFullPath, "UTF-8")
		this.IS_BACKINGUP_RECENT := false
	}

	createArchiveBackup(backupDate) {
		archiveData := JSON.stringify(this.loadOneDay(, backupDate, 60 * 24 * this.cleanPeriod))
		monthFolder := "\" . SubStr(backupDate, 1, 6)
		backupFullPath := this.backup . monthFolder . "\" . backupDate . " - backup.json"

		if (!DirExist(this.backup . monthFolder)) {
			DirCreate(this.backup . monthFolder)
		}
		if (FileExist(backupFullPath)) {
			FileDelete(backupFullPath)
		}
		FileAppend(archiveData, backupFullPath, "UTF-8")
		run backupFullPath
	}

	restoreRecent() {
		recent := JSON.parse(FileRead(this.backup . "\recent.json", "UTF-8"))
		for snippet in recent {
			this.add(JSON.stringify(snippet))
		}
	}

	restoreArchiveOneDay(restoreDate) {
		monthFolder := "\" . SubStr(restoreDate, 1, 6)
		loop files, (this.backup . monthFolder . "\*.json") {
			msgbox A_LoopFileName
			if (!InStr(A_LoopFileName, restoreDate)) {
				continue
			}

			archive := FileRead(A_LoopFileFullPath, "UTF-8")
			filename := StrReplace(A_LoopFileName, "backup", "archive")
			archiveFullPath := this.archive . "\" . filename

			if (FileExist(archiveFullPath)) {
				FileDelete(archiveFullPath)
			}
			FileAppend(archive, archiveFullPath, "UTF-8")
			break
		}
	}
}