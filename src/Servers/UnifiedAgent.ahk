class UnifiedAgent extends useServerAgent {
    __New(serverSettings) {
        super.__New(serverSettings)
        this.qmPool := serverSettings.HasOwnProp("qmPool") ? serverSettings.qmPool : A_ScriptDir . "\Servers\qm-pool"
        effect(this.isListening, cur => this.listen(cur))

        ; ongoing post
        this.currentHandlingPost := ""

        ; QM2 modules
        this.qmModules := Map(
            "BlankShare", BlankShare_Action,
            "PaymentRelation", PaymentRelation_Action
        )

        ; binding methods timer methods
        this.res := ObjBindMethod(this, "keepAlive")
        this.handlePost := ObjBindMethod(this, "postHandler")

        ; delete expired posts
        this.cleanup()
        this.cleanup(this.qmPool)
    }

    cleanup(pool := this.pool) {
        exp := this.expiration
        loop files (pool . "\*.json") {
            header := StrSplit(A_LoopFileName, "==")
            method := header[1]
            date := SubStr(header[3], 1, 14)
            if (DateDiff(A_Now, date, "Minutes") >= exp) {
                FileDelete(A_LoopFileFullPath)
            }
        }
    }

    abort(pool := this.pool) {
        if (!this.currentHandlingPost) {
            return
        }

        loop files (pool . "\*.json") {
            if (InStr(A_LoopFileName, this.currentHandlingPost["id"])) {
                this.updatePostStatus(A_LoopFileFullPath, "ABORTED")
            }
        }
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
     * <Agent>
     * @param status 
     */
    listen(status) {
        if (status == "在线") {
            SetTimer(() => this.InputBlock(), -1)
            SetTimer(this.handlePost, this.interval)
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

        ; is handling post at the moment
        if (this.currentHandlingPost) {
            return
        }

        this.keepAlive()
        SetTimer(, 0)
        this.isListening.set("处理中...")

        pmnPosts := this.COLLECT("PENDING")
        qmPosts := this.COLLECT("PENDING", this.qmPool)
        
        if (pmnPosts.Length) {
            this.modifyPostedProfiles(pmnPosts)
        }
        
        if (qmPosts.Length) {
            this.executeQmPostedActions(qmPosts)
        }

        this.currentHandlingPost := ""
        this.isListening.set("在线")
    }
    
    /**
     * <Agent>
     * @param {String[]} posts 
    */
   modifyPostedProfiles(posts) {
        unboxedPosts := posts.map(postPath => JSON.parse(FileRead(postPath, "UTF-8")))

        for post in unboxedPosts {
            this.RESPONSE()

            this.currentHandlingPost := post
            c := post["content"]
            if (c["mode"] == "waterfall" || c["mode"] == "single") {
                PMN_Waterfall.cascade(c["profiles"], c["overwrite"], c["party"])
            }
            this.updatePostStatus(posts[A_Index], "MODIFIED")
        }
    }

    /**
     * <Agent>
     * @param {String[]} posts 
     */
    executeQmPostedActions(posts) {
        unboxedPosts := posts.map(postPath => JSON.parse(FileRead(postPath, "UTF-8")))

        for post in unboxedPosts {
            this.RESPONSE()

            this.currentHandlingPost := post
            ; call QM action module
            ObjBindMethod(this.qmModules[post["content"]["module"]], "USE", post["content"]["form"]).Call()

            this.updatePostStatus(posts[A_Index], "MODIFIED")
        }
    }

    /**
     * <Client> Send post to pool
     * @param content post content to send
     */
    delegate(content) {
        c := useProps(content, 
            content.HasOwnProp("form") 
                ? { ; QM post
                    module:   content.module, ; QM2 module name
                    form:     content.form,   ; form data from module component
                    profiles: []              ; profiles from QM2 Panel
                } : { ; PMN post
                    mode:      "waterfall", ; single/waterfall/group
                    overwrite: false,       ; isOverwrite value
                    rooms:     [],          ; waterfall/group room numbers
                    party:     "",          ; optional party number for confinement 
                    profiles:  [],          ; json object in single, array in waterfall/group
                }
        )

        return this.POST(c.toObject(), content.HasOwnProp("form") ? this.qmPool : this.pool)
    }
}
