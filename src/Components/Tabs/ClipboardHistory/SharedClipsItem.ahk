ShareClipsItem(App, sharedClipHistory, index) {    
    icon := computed(sharedClipHistory, curHistory => match(curHistory[index]["type"], Map("URL", "⇱", "Text", "",), "🗁"))

    effect(sharedClipHistory, handleCtrlVisibility)
    handleCtrlVisibility(curHistory) {
        App["sciPlaceHolder" . index].Visible := false
        App["sciCopyBtn" . index].Visible := false
        App["sciOpenBtn" . index].Visible := false
        App["sciOpenDirBtn" . index].Visible := false
        App["sciPic" . index].Visible := false
        
        
        if (curHistory[index]["type"] == "Image") {
            App["sciPic" . index].Value := FileExist(curHistory[index]["text"])
                ? curHistory[index]["text"]
                : IMAGES["ImageNotFound.png"]
            App["sciPic" . index].Visible := true
            App["sciOpenDirBtn" . index].Visible := true
            return
        }

        if (curHistory[index]["type"].includes("file") 
            || curHistory[index]["type"] == "Folder" 
            || curHistory[index]["type"] == "URL"
        ) {
            App["sciOpenBtn" . index].Visible := true
            App["sciOpenDirBtn" . index].Visible := true
            return
        }

        App["sciPlaceHolder" . index].Visible := true
        App["sciCopyBtn" . index].Visible := true
    }


    handleHistoryTextCopy(ctrl, index) {
		A_Clipboard := sharedClipHistory.value[index]["text"]
		
		ctrl.Enabled := false
		ctrl.SetFont("s10")
		ctrl.Text := "☑"

		SetTimer(() => (
			ctrl.Text := "⿻", 
			ctrl.SetFont("s14"),
			ctrl.Enabled := true
		), -1000)
	}

    handleOpenDir(*) {
        Run CONFIG.read("sharedClipsDirMeta")
    }

    handleOpenFromPath(*) {
        try {
            Run sharedClipHistory.value[index]["text"]
        } catch Error as e {
            MsgBox("无法找到指定文件（它可能已被移动、重命名或删除）", POPUP_TITLE, "4096 T2")
        }
    }

    onMount() {
        handleCtrlVisibility(sharedClipHistory.value)
    }

    return (
        App.ARGroupBox("Section w350 r3 x340" . (index == 1 ? " y+9 " : " y+15 "), "{1}", sharedClipHistory, { index: index, keys: ["type"] }).SetFont("bold"),
        
        ; clipboard text
        App.AREdit("ReadOnly xs10 yp+20 w230 r3", "{1}", sharedClipHistory, { index: index, keys: ["text"] }),
        
        ; copy btn
        App.ARButton(("vsciCopyBtn" . index) . " x+0 w49 h49", "⿻").SetFont("s14")
           .OnClick((ctrl, _) => handleHistoryTextCopy(ctrl, index)),
        
        ; dir open btn
        App.ARButton(("vsciOpenDirBtn" . index) . " xp+0 yp+0 w49 h49", "🗀").SetFont("s14")
           .OnClick(handleOpenDir),

        ; placeholder btn
        App.AddButton(("vsciPlaceHolder" . index) . " x+0 w49 h49", ""),
        
        ; file open btn
        App.ARButton(("vsciOpenBtn" . index) . " xp+0 yp+0 w49 h49 Hidden", "{1}", icon).SetFont("s14")
           .OnClick(handleOpenFromPath),
        
        ; image preview
        App.AddPic(("vsciPic" . index) . " xp+0 yp+0 w49 h49 0x40 Hidden", "")
           .OnEvent("Click", handleOpenFromPath),

        onMount()
    )
}