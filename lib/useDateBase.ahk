class useDateBase {
	__New(dbSetting) {
		s := useProps(dbSetting, {
			main: dbSetting.main,
			backup: "",
			cleanPeriod: 0,
		})

		this.main := s.main
		this.backup := s.backup
		this.cleanPeriod := s.cleanPeriod

		if (!DirExist(this.main)) {
			DirCreate(this.main)
		}

		if (this.backup != "" && !DirExist(this.backup)) {
			DirCreate(this.backup)
		}
	}

	/**
	 * Adds a new record to a certain date file.
	 * @param {String} jsonString new record in JSON format.
	 * @param {String} date a date string in "yyyyMMdd" format.
	 */
	add(jsonString, date := A_Now) {
		SetTimer(() => this.addSync(jsonString, date, true), 1000)
	}

	addSync(jsonString, date := A_Now, isAsync := false) {
		checkType(jsonString, String)
		checkType(date, IsTime)
		date := FormatTime(date, "yyyyMMdd")

		err := false
		collection := Format("{1}\{2}.json", this.main, date)

		try {
			if (!FileExist(collection)) {
				FileAppend("[]", collection, "UTF-8")
			}

			if (InStr(FileGetAttrib(collection), "T")) {
				return
			} else {
				FileSetAttrib("+T", collection)
			}

			data := JSON.parse(FileRead(collection, "UTF-8"))
			data.Push(JSON.parse(jsonString))

			f := FileOpen(collection, "w", "UTF-8")
			f.Write(JSON.stringify(data))
			f.Close()
			FileSetAttrib("-T", collection)

		} catch Error as e {
			err := e
		}

		if (isAsync && !err) {
			SetTimer(, 0)
		}
	}

	/**
	 * Loads data in base on date/minute filter.
	 * @param {String} db database folder dir.
	 * @param {String} date a date string in "yyyyMMdd" format.
	 * @param {Integer} range a filter of range in minutes.
	 * @returns {Array}
	 */
	load(db := this.main, date := A_Now, range := 60) {
		checkType(date, IsTime)
		checkType(range, Integer)
		date := FormatTime(date, "yyyyMMdd")

		if (DateDiff(A_Now, date, "Days") < 0) {
			return []
		}

		collection := Format("{1}\{2}.json", this.main, date)
		backup := this.backup . "\" . SubStr(date, 1, 6) . "\" . date . "_backup.json"
		if (date != FormatTime(A_Now, "yyyyMMdd")) {
			range := 60 * 24 * (DateDiff(A_Now, date, "Days") + 1)
		}

		if (!FileExist(collection) && !FileExist(backup) && !(DateDiff(A_Now, date, "Days") > 0)) {
			FileAppend("[]", collection, "UTF-8")
		} else if (!FileExist(collection) && FileExist(backup)) {
			this.restoreBackup(date)
		} 
 
		data := JSON.parse(FileRead(collection, "UTF-8"))
		            .filter(item => DateDiff(A_Now, item["regTime"], "Minutes") <= range)
		            ; .filter(item => DateDiff(A_Now, SubStr(item["fileName"], 1, 12) , "Minutes") <= range)

		return data
	}

	/**
	 * Updates a single record in database main and backup.
	 * @param {String} newJsonString new record.
	 * @param {String} date date("yyyyMMdd") of the original record.
	 * @param {Func} matchingFn  callback function.
	 */
	updateOne(newJsonString, date, matchingFn) {
		SetTimer(() => this.updateOneSync(newJsonString, date, matchingFn, true))
	}

	updateOneSync(newJsonString, date, matchingFn, isAsync := false) {
		checkType(newJsonString, String)
		checkType(date, IsTime)
		checkType(matchingFn, Func)
		date := FormatTime(date, "yyyyMMdd")

		err := false
		collection := Format("{1}\{2}.json", this.main, date)

		try {
			if (InStr(FileGetAttrib(collection), "T")) {
				return
			} else {
				FileSetAttrib("+T", collection)
			}

			data := JSON.parse(FileRead(collection, "UTF-8"))
			data[data.findIndex(item => matchingFn(item))] := JSON.parse(newJsonString)

			f := FileOpen(collection, "w", "UTF-8")
			f.Write(JSON.stringify(data))
			f.Close()
			FileSetAttrib("-T", collection,)

			if (this.backup != "") {
				this.createBackup(date)
			}

		} catch Error as e {
			err := e
		}

		if (isAsync && !err) {
			SetTimer(, 0)
		}
	}

	/**
	 * Creates a backup copy to backup foler.
	 * @param {String} date date("yyyyMMdd") to be backup.
	 */
	createBackup(date) {
		checkType(date, IsTime)
		date := FormatTime(date, "yyyyMMdd")

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

	/**
	 * Restores database json of a certain date from backup.
	 * @param {String} date date date("yyyyMMdd") to be restore.
	 */
	restoreBackup(date) {
		checkType(date, IsTime)
		date := FormatTime(date, "yyyyMMdd")

		collection := Format("{1}\{2}.json", this.main, date)
		monthFolder := "\" . SubStr(date, 1, 6)

		if (!DirExist(this.backup . monthFolder)) {
			DirCreate(this.backup . monthFolder)
		}

		FileCopy(this.backup . monthFolder . "\" . date . "_backup.json", collection, true)
	}
}