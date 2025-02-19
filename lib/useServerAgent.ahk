class useServerAgent {
    __New(serverSettings) {
        s := useProps(serverSettings, {
            pool: "",         ; post pool dir path
            interval: 3000,   ; post checking interval MILLISECONDS
            expiration: 1,    ; delete posts after (exp) DAYS
            collectRange: 15, ; collect post from recent MINUTES
            safePost: true,   ; whether ping before sending a post
            isListening: serverSettings is Map 
                ? serverSettings["isListening"] 
                : serverSettings.isListening ; isListening depend signal
        })

        this.pool := s.pool
        this.interval := s.interval
        this.expiration := s.expiration
        this.collectRange := s.collectRange
        this.safePost := s.safePost
        this.isListening := s.isListening

        if (!DirExist(this.pool)) {
            DirCreate(this.pool)
        }
    }

    updatePostStatus(postPath, newStatus) {
        curStatus := postPath.split("\").at(-1).replace(".json", "").split("==")[1]
        FileMove(postPath, postPath.replace(curStatus, newStatus))
    }

    PING() {
        ; send
        message := { method: "PING", sender: A_ComputerName, id: A_Now . A_MSec . Random(1, 100) }
        filename := Format("{1}\{2}=={3}=={4}.json", this.pool, message.method, message.sender, message.id)
        resMatcher := this.pool . "\*" . message.id . "*.json"
        FileAppend(JSON.stringify(message), filename, "UTF-8")
        
        ; wait for response
        loop {
            loop files, this.pool . "\*.json" {
                if (InStr(A_LoopFileName, message.id) && InStr(A_LoopFileName, "ONLINE")) {
                    responsedHeader := StrSplit(A_LoopFileName, "==")
                    FileDelete(A_LoopFileFullPath)
                    return {
                        method: responsedHeader[1],
                        sender: responsedHeader[2],
                        id: responsedHeader[3]
                    }
                } 
            }

            Sleep 1000
            ; response timeout
            if(A_Index > (this.interval / 1000 * 3 * 3)) {
                try {
                    FileDelete(filename)
                }
                return false
            }
        }
    }

    RESPONSE() {
        loop files, this.pool . "\*.json" {
            if (InStr(A_LoopFileName, "PING")) {
                header := StrSplit(A_LoopFileName, "==")
                responseHeader := Format("{}=={}=={}", "ONLINE", A_ComputerName, header[3])
                FileMove(
                    A_LoopFileFullPath, 
                    StrReplace(A_LoopFileFullPath, A_LoopFileName, responseHeader)
                )
                return responseHeader
            }
        }
    }

    /**
     * <client> Post to pool
     * @param {Object} content 
     */
    POST(content) {
        if (this.safePost) {
            if (!this.PING()) {
                MsgBox("Service offline.",, "4096 T2")
                return
            }
        }

        message := {
            id: A_Now . A_MSec . Random(100, 999),
            method: "POST",
            sender: A_ComputerName,
            content: content
        }

        filename := Format("{1}\{2}=={3}=={4}.json", this.pool, "PENDING", A_ComputerName, message.id)
        FileAppend(JSON.stringify(message), filename, "UTF-8")

        return message
    }

    /**
     * <server> Collect posts
     * @param {String} method 
     * @returns {string[]} post filepaths array
     */
    COLLECT(status) {
        posts := []
        loop files (this.pool . "\*.json") {
            ; postTimestamp := SubStr(StrSplit(A_LoopFileName, "==")[3], 1, 14)
            postTimestamp := A_LoopFileName.split("==")[3].substr(1, 14)
            if (DateDiff(A_Now, postTimestamp, "Minutes") >= this.collectRange && A_LoopFileName.includes(status)) {

                this.updatePostStatus(A_LoopFileFullPath, "ABANDONED")
                continue
            }

            if (InStr(A_LoopFileFullPath, status)) {
                this.updatePostStatus(A_LoopFileFullPath, "COLLECTED")
                posts.Push(StrReplace(A_LoopFileFullPath, status, "COLLECTED"))
            }
        }

        return posts
    }
}