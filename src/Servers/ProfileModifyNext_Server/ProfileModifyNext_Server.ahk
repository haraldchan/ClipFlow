#Include "../../../lib/AddReactive/useAddReactive.ahk"
#Include "../../ActionModules/action-module-index.ahk"

class useServer {
    __New(serverSettings) {
        s := useProps(serverSettings, {
            pool: "",       ; request pool
            interval: 3000  ; request checking interval
        })

        this.pool := s.pool
        this.interval := s.interval

        if (!DirExist(this.pool)) {
			DirCreate(this.pool)
		}
    }

    TEST_CONNECTION() {
        ; send
        message := { method: A_ThisFunc, sender: A_ComputerName }
        filename := Format("{1}\{2}-{3}-{4}.json", this.pool, message.method, message.sender, A_Now . A_MSec)
        FileAppend(JSON.stringify(message), filename, "UTF-8")

        ; wait for response
        loop {
            if (FileExist(StrReplace(filename, A_ThisFunc, "ONLINE"))) {
                FileDelete(StrReplace(filename, A_ThisFunc, "ONLINE"))
                return true
            }
            Sleep 1000
            
            if(A_Index > this.interval / 1000 * 3) {
                FileDelete(filename)
                return false
            }
        }
    }

    /**
     * <client> Post to pool
     * @param {Object} content 
     */
    POST(content) {
        if (!this.TEST_CONNECTION()) {
            MsgBox("Service offline.",, "4096 T2")
            return
        }

        message := {
            id: A_Now . A_MSec . Random(1, 100),
            method: A_ThisFunc,
            sender: A_ComputerName,
            status: "PENDING",
            content: content
        }

        filename := Format("{1}\{2}-{3}-{4}.json", this.pool, A_ThisFunc, A_ComputerName, message.id)
        FileAppend(JSON.stringify(message), filename, "UTF-8")
    }

    /**
     * <server> Handle posts
     */
    HANDLE(method := "POST") {
        posts := []
        loop files (this.pool . "\*.json") {
            if (InStr(A_LoopFileFullPath, method)) {
                posts.Push(JSON.stringify(FileRead(A_LoopFileFullPath, "UTF-8")))
            }
        }

        for post in posts {
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

class ProfileModifyNext_Server extends useServer {
    __New(serverSettings) {
        super.__New(serverSettings)
    }

    delegate(content){
        c := useProps(content, {
            mode:      "single", ; single/waterfall/group
            overwrite: false,    ; isOverwrite value
            rooms:     [],       ; waterfall/group room numbers
            profile:   [],       ; json object in single, array in waterfall/group
        })

        this.POST(c)
    }
}