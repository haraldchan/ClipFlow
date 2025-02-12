class ProfileModifyNext_Agent extends useServerAgent {
    __New(serverSettings) {
        super.__New(serverSettings)     
        effect(this.isListening, cur => this.listen(cur)) 
        ; delete expired posts
        ; this.cleanup()

        ; binding methods timer methods
        this.res := ObjBindMethod(this, "RESPONSE")
        this.mod := ObjBindMethod(this, "modifyPostedProfiles")
    }

    cleanup() {
        exp := this.expiration
        loop files (this.pool "\*.json") {
            header := StrSplit(A_LoopFileName, "==")
            method := header[1]
            date := SubStr(header[3], 1, 14)
            if (DateDiff(A_Now, date, "Days") > exp) {
                FileDelete(A_LoopFileFullPath)
            }
        }
    }

    delegate(content) {
        c := useProps(content, {
            mode:      "single", ; single/waterfall/group
            overwrite: false,    ; isOverwrite value
            rooms:     [],       ; waterfall/group room numbers
            ; TODO: PMN_Waterfall needs to update to work with this
            party:     "",       ; optional party number for confinement 
            profiles:  [],       ; json object in single, array in waterfall/group
        })

        this.POST(c.toObject())
    }

    listen(status) {
        SetTimer(this.res, status == "在线" ? this.interval : 0)
        SetTimer(this.mod, status == "在线" ? this.interval : 0)
        
        ; blocks input while listening
        if (status == "在线") {
            BlockInput true
            Hotkey("{Esc}", (*) => BlockInput(false), "On")
            if (MsgBox("Profile Modify 代行服务运行中...`n`n按下 Esc 接触锁定`n点击确定停止服务", popupTitle, "4096") == "OK") {
                isListening.set("离线")
                BlockInput false
                Hotkey("{Esc}","Off")
            }
        }
    }

    listenSync(status) {
        if (status != "在线") {
            return
        }

        loop {
            this.RESPONSE()
            this.modifyPostedProfiles()
            Sleep this.interval
        }
    }

    modifyPostedProfiles() {
        posts := this.COLLECT("PENDING")
        if (posts.Length == 0) {
            return 
        }

        this.postHandler("PENDING", posts)
    }

    postHandler(method, posts) {
        this.isListening.set("处理中...")

        unboxedPosts := posts.map(postPath => JSON.parse(FileRead(postPath, "UTF-8")))
        for post in unboxedPosts {
            c := post["content"]
            if (c["mode"] == "waterfall" || c["mode"] == "single") {
                PMN_Waterfall.cascade(c["rooms"], c["profiles"], c["overwrite"])
            }

            ; rename file (change flag status & sender)
            FileMove(
                Format("{1}\{2}=={3}=={4}.json", this.pool, method, post["sender"], post["id"]),
                Format("{1}\{2}=={3}=={4}.json", this.pool, "MODIFIED", A_ComputerName, post["id"]),
            )
        }

        this.isListening.set("在线")
    }
}