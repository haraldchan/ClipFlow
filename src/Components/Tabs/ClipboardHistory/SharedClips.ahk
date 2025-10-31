#Include "./SharedClipsItem.ahk"

SharedClips(App, sendToSharedClips) {
    SHARED_CLIPS_DIR := CONFIG.read("sharedClipsDir")
    PAGE_LENGTH := 5

    clipTemplate := { type: "", text: "", contentPath: "" }
    
    pageIndex := 1
    sharedClipHistoryAll := []
    initSharedClipHistory()
    sharedClipHistory := signal(sharedClipHistoryAll.slice(pageIndex, PAGE_LENGTH + 1))


    initSharedClipHistory(*) {
        sharedClipHistoryAll := []
        pageIndex := 1

        loop files, SHARED_CLIPS_DIR . "\*.json" {
            sharedClipHistoryAll.InsertAt(1, JSON.parse(FileRead(A_LoopFileFullPath, "UTF-8")))
        }

        if (Mod(sharedClipHistoryAll.Length, PAGE_LENGTH) || sharedClipHistoryAll.Length == 0) {
            loop 5 - Mod(sharedClipHistoryAll.Length, PAGE_LENGTH) {
                sharedClipHistoryAll.Push(clipTemplate)
            }
        }
    }

    handleRefresh(*) {
        initSharedClipHistory()
        sharedClipHistory.set(sharedClipHistoryAll.slice(pageIndex, pageIndex + PAGE_LENGTH))
    }

    handlePageFlip(ctrl, _) {
        if (ctrl.Text == "下一页") {
            pageIndex := pageIndex + 5 > sharedClipHistoryAll.Length 
                ? sharedClipHistoryAll.Length - PAGE_LENGTH + 1
                : pageIndex + 5
        } else if (ctrl.Text == "上一页") {
            pageIndex := pageIndex - 5 < 0 
                ? 1
                : pageIndex - 5
        }

        sharedClipHistory.set(sharedClipHistoryAll.slice(pageIndex, pageIndex + PAGE_LENGTH))
    }


    return (
        App.AddGroupBox("Section x330 y61 w380 r25", "Shared Clips").SetFont("s9 bold"),
        
        ; sync clips to SHARED_CLIPS_DIR
        App.AddCheckbox("xs15 yp+25 h20 " . (sendToSharedClips.value ? "Checked" : ""), "同步到共享剪贴板")
           .OnEvent("Click", (ctrl, _) => sendToSharedClips.set(ctrl.Value)),
        
        ; flip btns
        App.AddButton("x+35 w20 h20", "↻").OnEvent("Click", handleRefresh),
        App.AddButton("x+10 w80 h20", "上一页").OnEvent("Click", handlePageFlip),
        App.AddButton("x+10 w80 h20", "下一页").OnEvent("Click", handlePageFlip),

        ; shared clip items
        PAGE_LENGTH.times(() => ShareClipsItem(App, sharedClipHistory, A_Index))
    )
}