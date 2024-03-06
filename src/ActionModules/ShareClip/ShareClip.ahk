#Include "../../../Lib/Classes/utils.ahk"
#Include "../../../Lib/Classes/_JXON.ahk"
#Include "../../App.ahk"

class ShareClip {
    static name := "Share Clip"
    static title := "Flow Mode - " . this.name
    static popupTitle := "ClipFlow - " . this.name
    static scriptHost := SubStr(A_ScriptDir, 1, InStr(A_ScriptDir, "\", , -1, -1) - 1)
    static shareClipFolder := this.scriptHost . "\Lib\ClipFlow\SharedClips"
    static shareTxt := Format("{1}\{2}.txt", this.shareClipFolder, FormatTime(A_Now, "yyyyMMdd"))
    static prefix := Format("发送自: {1}, {2} `r`n", A_UserName, FormatTime(A_Now))
    static archiveDays := 5

    static USE(App) {
        OnClipboardChange this.listenAndSend
        ; create new txt
        if (!DirExist(this.shareClipFolder)) {
            DirCreate(this.shareClipFolder)
        }
        if (!FileExist(this.shareTxt)) {
            FileAppend("", this.shareTxt)
        }
        ; cleanup txts older than x days.
        loop files this.shareClipFolder "\*.txt" {
            if (DateDiff(FormatTime(A_Now, "yyyyMMdd"), SubStr(A_LoopFileName, 1, 8), "days") >= this.archiveDays) {
                FileDelete this.shareClipFolder . "\" . A_LoopFileName
            }
        }
        ;states
        global isListening := false
        global readyToSend := false

        ui := [
            App.AddGroupBox("R15.5 w250 y+20", this.title),
            App.AddCheckbox("vclbListener " . "xp+10 yp+20 h15", "监听剪贴板"),
            App.AddText("xp y+15", "1、发送剪贴板History"),
            App.AddButton("vsendHistoryBtn " . "xp h32 w230 y+10", "发送 History"),
            App.AddText("xp y+15", "2、发送一段文字"),
            App.AddEdit("vuserInputText " . "xp h80 w230 y+10", ""),
            App.AddButton("vsendTextBtn " . "xp h32 w230 y+10", "发送 文字"),
            App.AddText("xp y+15", "3、查看 Share 剪贴板内容"),
            App.AddButton("vshowShareClipboardBtn " . "xp h32 w230 y+10", "打开 剪贴板"),
        ]
        ; get controls
        clbListener := interface.getCtrlByName("clbListener" , ui)
        sendHistoryBtn := interface.getCtrlByName("sendHistoryBtn", ui)
        userInputText := interface.getCtrlByName("userInputText", ui)
        sendTextBtn := interface.getCtrlByName("sendTextBtn", ui)
        showShareClipboardBtn := interface.getCtrlByName("showShareClipboardBtn", ui)

        ; add events
        clbListener.OnEvent("Click", toggleListen)
        sendHistoryBtn.OnEvent("Click", sendHistory)
        userInputText.OnEvent("Change", checkInput)
        sendTextBtn.OnEvent("Click", sendUserInputText)
        showShareClipboardBtn.OnEvent("Click", showShareClipboard)

        ; callbacks
        toggleListen(*) {
            global isListening := !isListening
        }

        sendHistory(*) {
            his := IniRead(store, "ClipHistory", "clipHisArr")
            clipHistory := Jxon_Load(&his)
            if (!clipHistory.Length) {
                return
            }
            text := this.sendHistory(clipHistory)
            MsgBox(Format("已发送：`r`n{1}", text), this.popupTitle, "4096 T1")
        }

        checkInput(*) {
            readyToSend := (userInputText.Text = "") ? false : true
        }

        sendUserInputText(*) {
            if (!readyToSend) {
                return
            }
            text := this.sendUserInputText(userInputText.Text)
            userInputText.Value := ""
            MsgBox(Format("已发送：`r`n{1}", text), this.popupTitle, "4096 T1")
        }

        showShareClipboard(*) {
            this.showShareClipboard(showShareClipboardBtn)
            showShareClipboardBtn.Enabled := false
        }
    }

    static listenAndSend() {
        this := ShareClip
        if (isListening = true) {
            utils.filePrepend(this.prefix . A_Clipboard . "`r`n`r`n", this.shareTxt)
            MsgBox(this.prefix . A_Clipboard, this.popupTitle, "4096 T1")
        } else {
            return
        }
    }

    static sendHistory(clipHisArr) {
        text := this.prefix
        loop clipHisArr.Length {
            text .= clipHisArr[A_Index] . "`r`n"
        }
        utils.filePrepend(text . "`r`n`r`n", this.shareTxt)
        return text
    }

    static sendUserInputText(userInput) {
        utils.filePrepend(this.prefix . userInput . "`r`n`r`n", this.shareTxt)
        return this.prefix . userInput
    }

    static showShareClipboard(showShareClipboardBtn) {
        sharedText := FileRead(this.shareTxt)
        isAutoRefresh := false

        shareCLB := Gui(, "Share 剪贴板")
        ui := [
            shareCLB.AddEdit("vshareClipboard w300 h500 ReadOnly", sharedText),
            shareCLB.AddCheckbox("vautoRefresher h30 y+10 ", "自动刷新"),
            shareCLB.AddButton("vrefreshBtn w90 h30 x+20", "刷  新"),
            shareCLB.AddButton("vopenShareClbBtn w90 h30 x+20", "打开源文件"),
        ]
        shareCLB.Show()
        WinSetAlwaysOnTop true, "Share 剪贴板"

        autoRefresher := interface.getCtrlByName("autoRefresher", ui)
        shareClipboard := interface.getCtrlByName("shareClipboard", ui)
        refreshBtn := interface.getCtrlByName("refreshBtn", ui)
        openShareClbBtn := interface.getCtrlByName("openShareClbBtn", ui)

        autoRefresher.OnEvent("Click", toggleAutoRefresh)
        refreshBtn.OnEvent("Click", getUpdateSharedText)
        openShareClbBtn.OnEvent("Click", (*) => Run(this.shareTxt))
        shareCLB.OnEvent("Close", closeShareClipboardWin)

        toggleAutoRefresh(*){
            isAutoRefresh := !isAutoRefresh
            if (isAutoRefresh = true) {
                SetTimer(getUpdateSharedText, 3000)
            } else {
                SetTimer(getUpdateSharedText, 0)
            }
        }

        getUpdateSharedText(*) {
            updatedText := FileRead(this.shareTxt)
            shareClipboard.Value := updatedText
        }

        closeShareClipboardWin(*) {
            showShareClipboardBtn.Enabled := true
            SetTimer(getUpdateSharedText, 0)
        }
    }
}