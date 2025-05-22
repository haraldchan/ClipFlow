class ProfileModifyNext_Agent extends useServerAgent {
    __New(serverSettings) {
        super.__New(serverSettings)
        effect(this.isListening, this.listen) 

        ; ongoing post
        this.currentHandlingPost := ""
        
        ; binding methods timer methods
        this.res := ObjBindMethod(this, "keepAlive")
        this.handlePost := ObjBindMethod(this, "postHandler")
        
        ; delete expired posts
        this.cleanup()
    }

    cleanup() {
        exp := this.expiration
        loop files (this.pool "\*.json") {
            header := StrSplit(A_LoopFileName, "==")
            method := header[1]
            date := SubStr(header[3], 1, 14)
            if (DateDiff(A_Now, date, "Days") >= exp) {
                FileDelete(A_LoopFileFullPath)
            }
        }
    }

    abort() {
        if (!this.currentHandlingPost) {
            return
        }

        loop files (this.pool . "\*.json") {
            if (InStr(A_LoopFileName, this.currentHandlingPost["id"])) {
                this.updatePostStatus(A_LoopFileFullPath, "ABORTED")
            }
        }
    }

    /**
     * <Agent>
     * @param status 
     */
    listen(status) {
        SetTimer(this.res, status != "离线" ? this.interval : 0)
        SetTimer(this.handlePost, status == "在线" ? this.interval : 0)
        
        ; blocks input while listening
        if (status == "在线") {
            SetTimer(() => this.InputBlock(), -100)
        }
    }

    /**
     * <Agent>
     */
    keepAlive() {
        if (this.isListening.value == "在线") {
            try {
                WinActivate("ahk_class SunAwtFrame")
                Send "!r"
                utils.waitLoading()
            }
        }
        this.RESPONSE()
    }

    /**
     * <Agent>
     */
    postHandler() {
        if (!WinExist("ahk_class SunAwtFrame")) {
            MsgBox("后台 Opera PMS 不在线。", popupTitle, "4096 T1")
            this.isListening.set("离线")   
            return
        }
        posts := this.COLLECT("PENDING")
        if (posts.Length == 0) {
            return 
        }

        this.modifyPostedProfiles(posts)
    }

    /**
     * <Agent>
     * @param {String[]} posts 
     */
    modifyPostedProfiles(posts) {
        this.isListening.set("处理中...")

        unboxedPosts := posts.map(postPath => JSON.parse(FileRead(postPath, "UTF-8")))
        for post in unboxedPosts {
            this.currentHandlingPost := post
            c := post["content"]
            if (c["mode"] == "waterfall" || c["mode"] == "single") {
                PMN_Waterfall.cascade(c["rooms"], c["profiles"], c["overwrite"], c["party"])
            }
            this.currentHandlingPost := ""
            this.updatePostStatus(posts[A_Index], "MODIFIED")
        }

        this.isListening.set("在线")
    }

    /**
     * <Agent>
     */
    InputBlock() {
        if (WinExist("Server Agent")) {
            BlockInput true
            WinActivate("Server Agent")
            return
        }

        BlockInput true
        if (MsgBox("Profile Modify 代行服务运行中...`n`n1.按下 Ctrl+Alt+Del 解锁键鼠`n2.点击确定停止服务", "Server Agent", "4096") == "OK") {
            this.isListening.set("离线")
            BlockInput false
        }
    }

    /**
     * <Client> Send post to pool
     * @param content post content to send
     */
    delegate(content) {
        c := useProps(content, {
            mode:      "waterfall", ; single/waterfall/group
            overwrite: false,       ; isOverwrite value
            rooms:     [],          ; waterfall/group room numbers
            party:     "",          ; optional party number for confinement 
            profiles:  [],          ; json object in single, array in waterfall/group
        })

        return this.POST(c.toObject())
    }
}