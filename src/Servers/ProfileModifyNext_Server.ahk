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
}

class ProfileModifyNext_Agent extends useServerAgent {
    __New(serverSettings) {
        super.__New(serverSettings)     
        effect(this.isListening, cur => this.listen(cur)) 
        ; delete expired posts
        ; this.cleanup()
        this.res := ObjBindMethod(this, "RESPONSE")
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

    listen(status := "在线") {
        SetTimer(this.res, status == "在线" ? this.interval : 0)
        ; SetTimer(this.modifyPostedProfiles, status == "在线" ? this.interval : 0)
    }

    modifyPostedProfiles() {
        this.isListening.set("处理中...")
        posts := this.COLLECT("PENDING")
        
        if (posts.Length == 0) {
            this.isListening.set("在线")
            return 
        }

        this.postHandler("PENDING", posts)
        this.isListening.set("在线")
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