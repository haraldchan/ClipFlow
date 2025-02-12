class useServerAgent {
    __New(serverSettings) {
        s := useProps(serverSettings, {
            pool: "",       ; post pool dir path
            interval: 3000, ; post checking interval
            expiration: 1,   ; delete posts after (exp) days
            isListening: ""
        })

        this.pool := s.pool
        this.interval := s.interval
        this.expiration := s.expiration
        this.isListening := s.isListening

        if (!DirExist(this.pool)) {
			DirCreate(this.pool)
		}
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
            if(A_Index > (this.interval / 1000 * 3)) {
                FileDelete(filename)
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
        if (!this.PING()) {
            MsgBox("Service offline.",, "4096 T2")
            return
        }

        message := {
            id: A_Now . A_MSec . Random(1, 100),
            method: "POST",
            sender: A_ComputerName,
            content: content
        }

        filename := Format("{1}\{2}=={3}=={4}.json", this.pool, "PENDING", A_ComputerName, message.id)
        FileAppend(JSON.stringify(message), filename, "UTF-8")
    }

    /**
     * <server> Collect posts
     * @param {String} method 
     * @returns {string[]} post filepaths array
     */
    COLLECT(method) {
        posts := []
        loop files (this.pool . "\*.json") {
            if (InStr(A_LoopFileFullPath, method)) {
                posts.Push(A_LoopFileFullPath)
            }
        }

        return posts
    }
}