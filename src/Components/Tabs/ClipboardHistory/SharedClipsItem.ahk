ShareClipsItem(App, sharedClipHistory, index) {
    ; thisImagePath := computed(sharedClipHistory, setImagePath)
    ; setImagePath(curHistory) {        
    ;     if (curHistory[index]["type"] == "Image") {
    ;         return FileExist(curHistory[index]["text"]) ? curHistory[index]["text"] : IMAGES["ImageNotFound.png"]
    ;     }

    ;     return ""
    ; }
    
    icon := computed(sharedClipHistory, curHistory => match(curHistory[index]["type"], Map("URL", "⇱", "Text", "",), "🗁"))

    effect(sharedClipHistory, handleCtrlVisibility)
    handleCtrlVisibility(curHistory) {
        App["sciPlaceHolderR" . index].Visible := false
        App["sciCopyBtn" . index].Visible := false
        App["sciOpenBtn" . index].Visible := false
        App["sciOpenDirBtn" . index].Visible := false
        App["sciPic" . index].Visible := false
        
        if (curHistory[index]["type"] == "Image") {
            App["chiPic" . index].Value := FileExist(curHistory[index]["text"])
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

        App["sciPlaceHolderR" . index].Visible := true
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
        Run sharedClipHistory.value[index]["text"]
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

        ; placeholder r btn
        App.AddButton(("vsciPlaceHolderR" . index) . " x+0 w49 h49", ""),
        
        ; file open btn
        App.ARButton(("vsciOpenBtn" . index) . " xp+0 yp+0 w49 h49 Hidden", "{1}", icon).SetFont("s14")
           .OnClick(handleOpenFromPath),
        
        ; image preview
        App.AddPic(("vsciPic" . index) . " xp+0 yp+0 w49 h49 0x40 Hidden", "")
           .OnEvent("Click", handleOpenFromPath),

        onMount()
    )
}