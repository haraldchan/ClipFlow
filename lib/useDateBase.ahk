class useDateBase {
	__New(dbSetting) {
		s := useProps(dbSetting, {
			main: dbSetting.main,
			backup: "",
			cleanPeriod: 0,
			splitDays: 20
		})

		this.main := s.main
		this.backup := s.backup
		this.cleanPeriod := s.cleanPeriod
		this.splitDays := s.splitDays

		if (!DirExist(this.main)) {
			DirCreate(this.main)
		}

		if (this.backup != "" && !DirExist(this.backup)) {
			DirCreate(this.backup)
		}
	}

	/**
	 * Returns an Object with target partition filepath and filename.
	 * @param {String} date query date
	 * @param {String} dir query db (main/backup)
	 * @returns {Object} 
	 */
	getPartition(date := A_Now, dir := this.main) {
		checkType(date, IsTime)
		checkType(dir, String)
		date := FormatTime(date, "yyyyMMdd")

		dateLoop := date
		loop this.splitDays - 1 {
			targetPartitonPath := Format("{1}\{2}{3}.json", dir, dateLoop, dir == this.main ? "" : "_backup")

			if (FileExist(targetPartitonPath)) {
				if (dir == this.main) {
					return {
						path: targetPartitonPath,
						filename: dateLoop
					}
				} else if (dir == this.backup) {
					return this.restoreBackup(date)
				}
			}

			dateLoop := FormatTime(DateAdd(dateLoop, -1, "Days"), "yyyyMMdd")
		}

		; if loop finished and not found,
		; try finding it in backup
		if (dir == this.main) {
			return this.getPartition(date, this.backup)
		}

		; if still not found, create a new one
		if (dir == this.backup) {
			newPartition := {
				path:  Format("{1}\{2}.json", this.main, date),
				filename: date
			}
			FileAppend(JSON.stringify(Map(date, [])), newPartition.path, "UTF-8")
			return newPartition
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
		
		err := false
		date := FormatTime(date, "yyyyMMdd")
		newRecord := JSON.parse(jsonString)
		partition := this.getPartition(date)

		try {
			; check is writing flag "T"
			if (InStr(FileGetAttrib(partition.path), "T")) {
				return
			} else {
				FileSetAttrib("+T", partition.path)
			}
			; retrive and insert new data
			data := JSON.parse(FileRead(partition.path, "UTF-8"))
			if (data.has(date)) {
				data[date].InsertAt(1, newRecord)
			} else {
				data[date] := [newRecord]
			}

			f := FileOpen(partition.path, "w", "UTF-8")
			f.Write(JSON.stringify(data))
			f.Close()
			FileSetAttrib("-T", partition.path)

		} catch Error as e {
			err := e
		}

		if (isAsync && !err) {
			SetTimer(, 0)
		}
	}

	/**
	 * Loads data in base on date/minute filter.
	 * @param {String} date a date string in "yyyyMMdd" format.
	 * @param {Integer} range a filter of range in minutes.
	 * @returns {Map}
	 */
	load(date := A_Now, range := 60) {
		checkType(date, IsTime)
		checkType(range, Integer)
		if (DateDiff(A_Now, date, "Days") < 0) {
			return []
		}

		date := FormatTime(date, "yyyyMMdd")
		if (date != FormatTime(A_Now, "yyyyMMdd")) {
			range := 60 * 24 * (DateDiff(A_Now, date, "Days") + 1)
		}

		partition := this.getPartition(date)
		data := JSON.parse(FileRead(partition.path, "UTF-8"))[date]
		            ; .filter(item => DateDiff(A_Now, item["regTime"], "Minutes") <= range)
		            .filter(item => DateDiff(A_Now, SubStr(item["fileName"], 1, 12) , "Minutes") <= range)

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

		err := false
		date := FormatTime(date, "yyyyMMdd")
		partition := this.getPartition(date)
		newRecord := JSON.parse(newJsonString)

		try {
			if (InStr(FileGetAttrib(partition.path), "T")) {
				return
			} else {
				FileSetAttrib("+T", partition.path)
			}

			data := JSON.parse(FileRead(partition.path, "UTF-8"))
			index := data[date].findIndex(item => matchingFn(item))
			data[date][index] := newRecord

			f := FileOpen(partition.path, "w", "UTF-8")
			f.Write(JSON.stringify(data))
			f.Close()
			FileSetAttrib("-T", partition.path)

			if (this.backup != "") {
				this.createBackup(partition)
			}

		} catch Error as e {
			err := e
		}

		if (isAsync && !err) {
			SetTimer(, 0)
		}
	}

	createBackup(partition) {
		checkType(partition.filename, IsTime)

		if (!FileExist(partition.path)) {
			return
		}

		FileCopy(partition.path, this.backup . "\" . partition.filename . "_backup.json", true)
	}

	restoreBackup(date) {
		checkType(date, IsTime)

		backupPartition := this.getPartition(date, this.backup)

		backupPath := Format("{1}\{2}_backup.json", this.backup, backupPartition.path)
		partitionPath := Format("{1}\{2}.json", this.main, backupPartition.filename)

		FileCopy(backupPath, partitionPath, true)
		
		return {
			path: partitionPath,
			filename: backupPartition.filename
		}
	}
}