ClipHistoryItem(App, clipHistory, index, style) {
    icon := computed(clipHistory, curHistory => curHistory[index]["type"] == "URL" ? "⇱" : "🗁")
    
    effect(clipHistory, handleCtrlVisibility)
    handleCtrlVisibility(curHistory) {
        App["chiPlaceHolder" . index].Visible := false
        App["chiCopyBtn" . index].Visible := false
        App["chiOpenBtn" . index].Visible := false
        App["chiPic" . index].Visible := false
        
        if (curHistory[index]["type"] == "Image") {
            App["chiPic" . index].Value := FileExist(curHistory[index]["text"])
                ? curHistory[index]["text"]
                : IMAGES["ImageNotFound.png"]
            App["chiPic" . index].Visible := true
            return
        }

        if (curHistory[index]["type"].includes("file") 
            || curHistory[index]["type"] == "Folder" 
            || curHistory[index]["type"] == "URL"
        ) {
            App["chiOpenBtn" . index].Visible := true
            return
        }

        if (curHistory[index]["type"] == "Text") {
            App["chiCopyBtn" . index].Visible := true
            return
        }

        App["chiPlaceHolder" . index].Visible := true
    }

    handleOpenFromPath(*) {
        try {
            Run clipHistory.value[index]["text"]
        } catch Error as e {
            MsgBox("无法找到指定文件（它可能已被移动、重命名或删除）", POPUP_TITLE, "4096 T2")
        }
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

    handleHistoryContentCopy(ctrl, _) {
        Sleep 200
        A_Clipboard := clipHistory.value[index]["content"]
        copyBtn := App["chiCopyBtn" . index]

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
        App["chiPic" . index].OnEvent("DoubleClick", handleOpenFromPath) 
        handleCtrlVisibility(clipHistory.value)
    }

    return (
        App.ARGroupBox("Section w300 r3" . style.x . style.y, "{1}", clipHistory, { index: index, keys: ["type"] }).SetFont("bold"),

        ; non-display btn, just to prevent focusing on the edit
        App.AddButton("x+1 w0 h0", ""), 

        ; clipboard text
        App.AREdit("ReadOnly xs10 yp+20 w230 r3", "{1}", clipHistory, { index: index, keys: ["text"] }),
        App.AddButton(("vchiPlaceHolder" . index) . " x+1 w49 h49", ""),
        
        ; text copy btn
        App.ARButton(("vchiCopyBtn" . index) . " xp+0 yp+0 w49 h49 Hidden", "⿻").SetFont("s14")
           .OnClick(handleHistoryTextCopy),
        ; file open btn
        App.ARButton(("vchiOpenBtn" . index) . " xp+0 yp+0 w49 h49 Hidden", "{1}", icon).SetFont("s14")
           .OnClick(handleHistoryContentCopy)
           .OnDoubleClick(handleOpenFromPath),
        ; image preview
        App.AddPic(("vchiPic" . index) . " xp+0 yp+0 w49 h49 0x40 Hidden", "")
           .OnEvent("Click", handleHistoryContentCopy)
        
        onMount()
    )
}