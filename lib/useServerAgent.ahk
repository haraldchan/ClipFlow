class useServerAgent {
    __New(serverSettings) {
        s := useProps(serverSettings, {
            pool: "",       ; post pool dir path
            interval: 3000, ; post checking interval
            expiration: 10  ; delete posts after (exp) days
        })

        this.pool := s.pool
        this.interval := s.interval
        this.expiration := s.expiration

        if (!DirExist(this.pool)) {
			DirCreate(this.pool)
		}
    }

    PING() {
        ; send
        message := { method: A_ThisFunc, sender: A_ComputerName, id: A_Now . A_MSec . Random(1, 100) }
        filename := Format("{1}\{2}-{3}-{4}.json", this.pool, message.method, message.sender, message.id)
        FileAppend(JSON.stringify(message), filename, "UTF-8")

        ; wait for response
        loop files (this.pool . "\*json") {
            header := StrSplit(A_LoopFileName, "-")
            if (header[3] == message.id && header[1] == "ONLINE") {
                return header
            }
            Sleep 1000
            
            if(A_Index > this.interval / 1000 * 3) {
                FileDelete(filename)
                return false
            }
        }
    }

    RESPONSE() {
        loop files (this.pool, "\*.json") {
            if (InStr(A_LoopFileName, "PING")) {
                header := StrSplit(A_LoopFileName, "-")
                responseHeader := Format("{}-{}-{}", "ONLINE", A_ComputerName, header[3])
                FileMove(A_LoopFileFullPath, StrReplace(A_LoopFileName, responseHeader))
                return
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
            method: A_ThisFunc,
            sender: A_ComputerName,
            content: content
        }

        filename := Format("{1}\{2}-{3}-{4}.json", this.pool, "PENDING", A_ComputerName, message.id)
        FileAppend(JSON.stringify(message), filename, "UTF-8")
    }

    /**
     * <server> Handle posts
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