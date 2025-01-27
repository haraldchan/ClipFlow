class useJsonDB {
	__New(dbSetting) {
		s := useProps(dbSetting, {
			main: dbSetting.main,
			backup: "",
			cleanPeriod: 0,
		})

		this.main := s.main
		this.backup := s.backup
		this.cleanPeriod := s.cleanPeriod
	}

	add(jsonString, date := FormatTime(A_Now, "yyyyMMdd")) {
		SetTimer(() => this.addSync(jsonString, date, true), 1000)
	}

	addSync(jsonString, date := FormatTime(A_Now, "yyyyMMdd"), isAsync := false) {
		collection := Format("{1}\{2}.json", this.main, date)
		if (!FileExist(collection)) {
			FileAppend("[]", collection, "UTF-8")
		}
		; hidden while writing
		if (InStr(FileGetAttrib(collection), "H")) {
			return
		}

		; add H attribute indicate that it is writing
		f := FileOpen(collection, "w", "UTF-8")
		FileSetAttrib("+H", collection)

		data := JSON.parse(FileRead(collection, "UTF-8"))
		data.Push(JSON.parse(jsonString))

		f.Write(JSON.stringify(data))
		f.Close()

		FileSetAttrib(collection, "-H")

		if (isAsync) {
			SetTimer(, 0)
		}
	}

	load(db := this.main, date := FormatTime(A_Now, "yyyyMMdd"), range := 60) {
		collection := Format("{1}\{2}.json", this.main, date)
		backup := this.backup . "\" . SubStr(date, 1, 6) . "\" . date . "_backup.json"

		if (!FileExist(collection) && !FileExist(backup)) {
			FileAppend("[]", collection, "UTF-8")
		} else if (!FileExist(collection) && FileExist(backup)) {
			FileAppend(FileRead(backup, "UTF-8"), collection, "UTF-8")
		}

		return JSON.parse(FileRead(collection, "UTF-8"))
	}

	updateOne(newJsonString, date, tsId) {
		SetTimer(() => this.updateOneSync(newJsonString, date, tsId, true))
	}

	updateOneSync(newJsonString, date, tsId, isAsync := false) {
		collection := Format("{1}\{2}.json", this.main, date)

		if (InStr(FileGetAttrib(collection), "H")) {
			return
		}

		f := FileOpen(collection, "w", "UTF-8")
		FileSetAttrib("+H", collection)

		data := JSON.parse(FileRead(collection, "UTF-8"))
		data[data.findIndex(item => item["tsId"] == tsId)] := JSON.parse(newJsonString)

		f.Write(JSON.stringify(data))
		f.Close()

		FileSetAttrib(collection, "-H")

		this.createBackup(date)

		if (isAsync) {
			SetTimer(, 0)
		}
	}

	createBackup(date) {
		collection := Format("{1}\{2}.json", this.main, date)
		monthFolder := "\" . SubStr(date, 1, 6)

		if (!FileExist(collection)) {
			return
		}

		if (!DirExist(this.backup . monthFolder)) {
			DirCreate(this.backup . monthFolder)
		}

		FileCopy(collection, this.backup . monthFolder . "\" . date . "_backup.json", true)
	}

	restoreBackup(date) {
		collection := Format("{1}\{2}.json", this.main, date)
		monthFolder := "\" . SubStr(date, 1, 6)

		if (!DirExist(this.backup . monthFolder)) {
			DirCreate(this.backup . monthFolder)
		}

		FileCopy(this.backup . monthFolder . "\" . date . "_backup.json", collection, true)
	}
}