class ProfileModifyNext_Client extends useServerAgent {
    __New(serverSettings) {
        super.__New(serverSettings)
    }

    delegate(content) {
        c := useProps(content, {
            mode:      "single", ; single/waterfall/group
            overwrite: false,    ; isOverwrite value
            rooms:     [],       ; waterfall/group room numbers
            profile:   [],       ; json object in single, array in waterfall/group
        })

        this.POST(c)
    }

    checkConnection(){
        return this.PING()
    }
}

class ProfileModifyNext_Agent extends useServerAgent {
    __New(serverSettings) {
        super.__New(serverSettings)     
        this.isListening := signal(false)   
        ; delete expired posts
        this.cleanup()
    }

    cleanup() {
        exp := super.expiration
        loop files (this.pool "\*.json") {
            header := StrSplit(A_LoopFileName, "-")
            method := header[1]
            date := SubStr(header[3], 1, 14)
            if (DateDiff(A_Now, date, "Days") > exp) {
                FileDelete(A_LoopFileFullPath)
            }
        }
    }

    listen(isListening := true) {
        this.isListening.set(isListening)
        SetTimer(this.RESPONSE, isListening ? this.interval : 0)
        SetTimer(this.modifyPostedProfiles, isListening ? this.interval : 0)
    }

    modifyPostedProfiles() {
        this.isListening.set(false)
        posts := this.COLLECT("PENDING")
        
        if (posts.Length == 0) {
            this.isListening.set(true)
            return 
        }

        this.postHandler("PENDING", posts)
        this.isListening.set(true)
    }

    postHandler(method, posts) {
        unboxedPosts := posts.map(postPath => JSON.parse(FileRead(postPath, "UTF-8")))
        for post in unboxedPosts {
            c := post["content"]
            switch post["content"]["mode"] {
                case "single":
                    PMN_FillIn.fill(c["profile"], c["overwrite"])
                case "waterfall":
                    PMN_Waterfall.cascade(c["rooms"], c["profile"], c["overwrite"])
                case "group":
                    PMNG_Execute.startModify(c["rooms"], c["profile"])
            }

            ; rename file (change flag status)
            FileMove(
                Format("{1}\{2}-{3}-{4}.json", this.pool, method, post.sender, post.id),
                Format("{1}\{2}-{3}-{4}.json", this.pool, "MODIFIED", post.sender, post.id),
            )
        }
    }
}