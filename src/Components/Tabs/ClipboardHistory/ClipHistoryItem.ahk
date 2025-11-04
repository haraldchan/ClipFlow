ClipHistoryItem(App, clipHistory, index, style) {
    i := SystemIcons.iconRef
    curIcon := i.ICON_BLANK

    effect(clipHistory, handleCtrlVisibility)
    handleCtrlVisibility(curHistory) {
        btn := App["chi-function-btn" . index]
        pic := App["chi-pic" . index]

        btn.removeIcon()
        btn.Visible := false
        pic.Visible := false

        if (!curHistory[index]["type"]) {
            btn.Visible := true
            return
        }
        else if (curHistory[index]["type"] == "Image") {
            pic.Value := FileExist(curHistory[index]["text"])
                ? curHistory[index]["text"]
                : IMAGES["ImageNotFound.png"]
            pic.Visible := true
            return
        }
        else if (curHistory[index]["type"] == "Text") {
            curIcon := i.ICON_TEXT
        }
        else {
            iconIndex := match(curHistory[index]["type"], Map(
                t => t.startsWith(".7z") || t.startsWith(".zip"), i.ICON_ZIP,
                t => t.startsWith(".doc"), i.ICON_WORD,
                t => t.startsWith(".xls"), i.ICON_EXCEL,
                t => t.startsWith(".ppt"), i.ICON_PPT,
                t => t.endsWith("file"), i.ICON_FILE,
                "Folder", i.ICON_FOLDER,
                "URL", i.ICON_URL,
            ))

            curIcon := iconIndex
            btn.Visible := true
        }

        btn.setIcon(curIcon)
        btn.Visible := true
    }


    handleOpenFromPath(ctrl, _) {
        try {
            if (clipHistory.value[index]["type"] == "Text") {
                return
            }
            
            Run(clipHistory.value[index]["text"])
        } catch Error as e {
            MsgBox("无法找到指定文件（它可能已被移动、重命名或删除）", POPUP_TITLE, "4096 T2")
        }
    }

    handleHistoryContentCopy(ctrl, _) {
        if (!clipHistory.value[index]["text"]) {
            return
        }

        Sleep 200
        
        A_Clipboard := clipHistory.value[index]["content"]
        btn := App["chi-function-btn" . index]
        pic := App["chi-pic" . index]
        isPic := ctrl is Gui.Pic

        pic.Visible := false
        btn.Visible := true
        btn.setIcon(i.ICON_COPIED)
        btn.Enabled := false

		SetTimer(() => (
            btn.Enabled := true,
            pic.Visible := isPic,
            btn.Visible := !isPic,
            btn.setIcon(curIcon)
		), -1000)
    }

    onMount() {
        App["chi-pic" . index].OnEvent("DoubleClick", handleOpenFromPath) 
        handleCtrlVisibility(clipHistory.value)
    }

    return (
        App.ARGroupBox("Section w300 r3" . style.x . style.y, "{1}", clipHistory, { index: index, keys: ["type"] }).SetFont("bold"),

        ; non-display btn, just to prevent focusing on the edit
        App.AddButton("x+1 w0 h0", ""), 

        ; copy/open file btn
        App.AREdit("ReadOnly xs10 yp+20 w230 r3", "{1}", clipHistory, { index: index, keys: ["text"] }),
        App.ARButton(("vchi-function-btn" . index) . " x+1 w49 h49 @IconOnly", "")
           .OnClick(handleHistoryContentCopy)
           .OnDoubleClick(handleOpenFromPath),
        
        ; image 
        App.AddPic(("vchi-pic" . index) . " xp+0 yp+0 w49 h49 0x40 Hidden", "")
           .OnEvent("Click", handleHistoryContentCopy)
        
        onMount()
    )
}