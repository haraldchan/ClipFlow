ClipboardHistory(App) {
    IMG_EXTS := ["jpg", "jpeg", "gif", "png", "tiff", "bmp", "ico"]
    CLIP_HISTORY_LENGTH := 6
    CLIP_HISTORY_DIR := A_MyDocuments . "\clipflow-clips"
    if (!DirExist(CLIP_HISTORY_DIR)) {
        DirCreate(CLIP_HISTORY_DIR)
    }
    
    clipTemplate := { type: "", text: "", content: "" }
    clipHistoryContent := []
    loop files, CLIP_HISTORY_DIR . "\*.clip" {
        A_Clipboard := ClipboardAll(FileRead(A_LoopFileFullPath, "RAW"))
        clipHistoryContent.InsertAt(1, handleContentSplit())
    } until (A_Index > CLIP_HISTORY_LENGTH)

    loop CLIP_HISTORY_LENGTH - clipHistoryContent.Length {
        clipHistoryContent.Push(clipTemplate)
    }

    clipHistory := signal(clipHistoryContent)

    OnClipboardChange((*) => (handleClipHistoryUpdate(), handleLocalClipsCleaning(), 1))
    handleClipHistoryUpdate() {
        if (clipHistory.value.find(c => c["text"] == A_Clipboard)) {
            return
        }

        newHistory := [clipHistory.value*]
        newHistory.InsertAt(1, handleContentSplit(true))

        if (newHistory.Length > CLIP_HISTORY_LENGTH) {
            newHistory.Pop()
        }

        clipHistory.set(newHistory)
    }

    handleContentSplit(saveClip := false) {
        SplitPath(A_Clipboard, &fileName, &dir, &ext, &_, &drive)

        capturedType := match(dir, OrderedMap(
            (*) => dir.slice(1,5) == "http", "URL",
            (*) => drive && IMG_EXTS.find(e => e == ext), "Image",
            (*) => !drive, "Text",
            (*) => drive && !ext, "Folder"
        ), Format(".{1} file", ext))

        if (saveClip) {
            FileAppend(ClipboardAll(), Format("{1}\{2}{3}.clip", CLIP_HISTORY_DIR, A_Now, A_MSec))
        }

        return {
            type: capturedType,
            text: A_Clipboard,
            content: ClipboardAll()
        }
    }

    handleLocalClipsCleaning() {
        clipList := []
        loop files, CLIP_HISTORY_DIR . "\*.clip" {
            SplitPath(A_LoopFileFullPath,,,,&filename)
            clipList.Push({
                filename: Integer(filename),
                fullpath: A_LoopFileFullPath
            })
        }

        sortedClipList := clipList.sort((a, b) => b.filename - a.filename)
        for clip in sortedClipList {
            if (A_Index <= CLIP_HISTORY_LENGTH) {
                continue
            }

            FileDelete(clip.fullpath)
        }
    }

    return CLIP_HISTORY_LENGTH.times(() => ClipHistoryBlock(App, clipHistory, A_Index))
}


ClipHistoryBlock(App, clipHistory, index) {
    icon := computed(clipHistory, curHistory => curHistory[index]["type"] == "URL" ? "⇱" : "🗁")
    thisImagePath := computed(clipHistory, curHistory => curHistory[index]["type"] == "Image" ? curHistory[index]["text"] : "")
    
    effect(clipHistory, handleCtrlVisibility)
    handleCtrlVisibility(curHistory) {
        App["chbPlaceHolder" . index].Visible := false
        App["chbCopyBtn" . index].Visible := false
        App["chbOpenBtn" . index].Visible := false
        App["chbPic" . index].Visible := false
        
        if (curHistory[index]["type"] == "Image") {
            App["chbPic" . index].Visible := true
            return
        }

        if (curHistory[index]["type"].includes("file") 
            || curHistory[index]["type"] == "Folder" 
            || curHistory[index]["type"] == "URL"
        ) {
            App["chbOpenBtn" . index].Visible := true
            return
        }

        if (curHistory[index]["type"] == "Text") {
            App["chbCopyBtn" . index].Visible := true
            return
        }

        App["chbPlaceHolder" . index].Visible := true
    }

    handleOpenFromPath(*) {
        Run clipHistory.value[index]["text"]
    }

    handleHistoryTextCopy(ctrl, _) {
		A_Clipboard := clipHistory.value[index]["text"]
		
		ctrl.Enabled := false
		ctrl.SetFont("s10")
		ctrl.Text := "☑"

		SetTimer(() => (
			ctrl.Text := "⿻", 
			ctrl.SetFont("s14"),
			ctrl.Enabled := true
		), -1000)
	}

    handleHistoryImageCopy(ctrl, _) {
        Sleep 200
        A_Clipboard := clipHistory.value[index]["content"]
        copyBtn := App["chbCopyBtn" . index]

        ctrl.Visible := false
        copyBtn.Visible := true
        copyBtn.Enabled := false
        copyBtn.SetFont("s10")
        copyBtn.Text := "☑"

		SetTimer(() => (
			copyBtn.Text := "⿻", 
			copyBtn.SetFont("s14"),
            copyBtn.Visible := false,
            copyBtn.Enabled := true,
            ctrl.Visible := true
		), -1000)
    }

    onMount() {
        handleCtrlVisibility(clipHistory.value)
    }

    return (
        App.ARGroupBox("Section x20 w300 r3 " . (index == 1 ? "y+10" : "y+20"), "{1}", clipHistory, { index: index, keys: ["type"] }).SetFont("bold"),
        App.AddButton("x+1 w0 h0", ""), ; just to prevent focusing on the edit
        App.AREdit("ReadOnly xs10 yp+20 w230 r3", "{1}", clipHistory, { index: index, keys: ["text"] }),
        App.AddButton(("vchbPlaceHolder" . index) . " x+1 w49 h49", ""),
        App.ARButton(("vchbCopyBtn" . index) . " xp+0 yp+0 w49 h49 Hidden", "⿻").SetFont("s14")
           .OnClick(handleHistoryTextCopy),
        App.ARButton(("vchbOpenBtn" . index) . " xp+0 yp+0 w49 h49 Hidden", "{1}", icon).SetFont("s14")
           .OnClick(handleOpenFromPath),
        App.ARPic(("vchbPic" . index) . " xp+0 yp+0 w49 h49 Hidden", thisImagePath)
           .OnClick(handleHistoryImageCopy)
           .OnDoubleClick(handleOpenFromPath),
        onMount()
    )
}