class QM2_Agent extends useServerAgent {
    __New(serverSettings) {
        super.__New(serverSettings)
        effect(this.isListening, cur => this.listen(cur))

        this.currentHandlingPost := ""
        this.moduleIndex := Map(
            "BlankShare", this.blankShareHandler
        )

        ; binding methods timer methods
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


    /**
     * <Agent>
     * @param status 
     */
    listen(status) {
        SetTimer(this.handlePost, status == "在线" ? this.interval : 0)
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

        this.isListening.set("处理中...")

        unboxedPosts := posts.map(postPath => JSON.parse(FileRead(postPath, "UTF-8")))
        for post in unboxedPosts {
            this.currentHandlingPost := post

            ; calls handler
            this.moduleIndex[post["module"]].Call()

            this.currentHandlingPost := ""
            this.updatePostStatus(post[A_Index], "MODIFIED")
        }

        this.isListening.set("在线")
    }


    /**
     * <Agent>
     * @param {String[]} posts 
     */
    blankSharehandler(post) {
        ; search
        MouseMove 329, 196 ; room number field
        Click 3
        utils.waitLoading()
        Send post["content"]["room"]
        utils.waitLoading()
        Send "!h" ; alt+h => search
        utils.waitLoading()
        ; call module's USE method
        BlankShare_Action.USE(post["content"]["checkIn"], post["content"]["shareQty"])
    }


    /**
     * <Client> Send post to pool
     * @param content post content to send
     */
    delegate(content) {
        ; c := useProps(content, {
        ;     module:   "",
        ;     room:     "",
        ;     shareQty: 1,
        ;     checkIn:  true
        ; })

        ; return this.POST(c.toObject())
        return this.POST(content)
    }
}