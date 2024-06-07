#Include "./JSON.ahk"
#Include "./AddReactive/AddReactive.ahk"

class useDebug {
    static logContent := signal("")

    static logLine(input) {
        if (input is String || input is Number) {
            return input
        } else if (input is Func) {
            return "Function: " . input.Name
        } else {
            return JSON.stringify(input)
        }
    }

    static msg(input) {
        MsgBox(this.logLine(input), "Debug")
    }

    static log(input) {
        hr := "------------------------------------------------------`r`n"
        logHistory := this.logContent.value
        this.logContent.set(logHistory . hr . this.logLine(input) . "`r`n")
    }

    ; timer1 := useDebug.time(timer1)
    class time {
        __New(label := 0) {
            this.label := label
            this.startTime := A_Now
        }
    }

    ; useDebug.timeEnd(timer1) => 1000ms
    class timeEnd {
        __New(timer) {
            this.timer := timer
            this.time := DateDiff(A_Now, timer.startTime, "Seconds") . "s"
            this.logMsg := Format("{1} ends within {2}", timer.label ? "timer: " . timer.label : "", this.time)

            useDebug.log(this.logMsg)
        }
    }

    static Console() {
        Console := Gui("+AlwaysOnTop", "Debug")
        Console.SetFont(, "微软雅黑")

        onTop := signal(true)
        effect(onTop, isOnTop => Console.Opt(isOnTop ? "+AlwaysOnTop" : "-AlwaysOnTop"))

        saveLog() {
            savePath := FileSelect("S 16")
            fileName := savePath . ".txt"

            useDebug.log(fileName)

            FileAppend(this.logContent.value, fileName, "UTF-8")
        }

        return (
            Console.AddCheckbox("h25 w170 Checked", "keep on-top").OnEvent("Click", (edit, _) => onTop.set(edit.value)),
            Console.AddButton("h25 x+10", "clear").OnEvent("Click", (*) => this.logContent.set(""))
            Console.AddButton("h25 x+10", "save log").OnEvent("Click", (*) => saveLog()),
            ; log window
            Console.AddReactiveEdit("x10 w300 h500 ReadOnly", "{1}", this.logContent),
            Console.Show()
        )
    }
}