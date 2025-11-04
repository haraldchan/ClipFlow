#Include "./ClipboardHistory/ClipHistoryItem.ahk"
#Include "./ClipboardHistory/SharedClips.ahk"

ClipboardHistory(App) {
    SHARED_CLIPS_DIR := CONFIG.read("sharedClipsDir")
    SHARED_CLIPS_DIR_META := CONFIG.read("sharedClipsDirMeta")
    IMG_EXTS := ["jpg", "jpeg", "gif", "png", "tiff", "bmp", "ico"]
    CLIP_HISTORY_LENGTH := 6
    CLIP_HISTORY_DIR := A_MyDocuments . "\clipflow-clips"
    if (!DirExist(CLIP_HISTORY_DIR)) {
        DirCreate(CLIP_HISTORY_DIR)
    }
    if (!DirExist(SHARED_CLIPS_DIR)) {
        DirCreate(SHARED_CLIPS_DIR)
    }

    sendToSharedClips := signal(CONFIG.read("sendToSharedClips"))
    effect(sendToSharedClips, isSend => CONFIG.write("sendToSharedClips", isSend))
    
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
        newHistory := [clipHistory.value*]
        newHistory.InsertAt(1, handleContentSplit(true))

        if (clipHistory.value.find(c => c["text"] == A_Clipboard)) {
            return
        }

        if (newHistory.Length > CLIP_HISTORY_LENGTH) {
            newHistory.Pop()
        }

        clipHistory.set(newHistory)
    }

    handleContentSplit(saveClip := false) {
        SplitPath(A_Clipboard, &fileName, &dir, &ext, &fileNameNoExt, &drive)

        capturedType := match(dir, OrderedMap(
            (*) => dir.slice(1,5) == "http", "URL",
            (*) => drive && IMG_EXTS.find(e => e == ext), "Image",
            (*) => !drive, "Text",
            (*) => drive && !ext, "Folder"
        ), Format(".{1} file", ext))

        timeStamp := A_Now . A_MSec
        rand := Random(100, 999)
        clipName := Format("{1}\{2}={3}.clip", CLIP_HISTORY_DIR, timeStamp, rand)

        if (saveClip) {
            FileAppend(ClipboardAll(), clipName)
        }

        if (saveClip && sendToSharedClips.value) {
            if (!DirExist(SHARED_CLIPS_DIR_META)) {
                DirCreate(SHARED_CLIPS_DIR_META)
            } 

            dest := SHARED_CLIPS_DIR_META . "\" . fileName

            jsonIndexer := {
                type: capturedType,
                text: capturedType == "Text" ? A_Clipboard : dest,
                contentPath: (capturedType.includes("file") || capturedType == "Image") ? dest : ""
            }

            ; copy file/image to meta dir
            if !(A_Clipboard == dest) {
                if (capturedType.includes("file") || capturedType == "Image") {
                    FileCopy(A_Clipboard, dest, true)
                }

                ; add json indexer
                FileAppend(
                    JSON.stringify(jsonIndexer), 
                    Format("{1}\{2}={3}.json", SHARED_CLIPS_DIR, timeStamp, rand), 
                    "UTF-8"
                )                    
            }  
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
                timeStamp: Integer(filename.split("=")[1]),
                fullpath: A_LoopFileFullPath
            })
        }

        sortedClipList := clipList.sort((a, b) => b.timeStamp - a.timeStamp)
        for clip in sortedClipList {
            if (A_Index <= CLIP_HISTORY_LENGTH) {
                continue
            }

            FileDelete(clip.fullpath)
        }
    }

    return (
        CLIP_HISTORY_LENGTH.times(() => ClipHistoryItem(App, clipHistory, A_Index, { x: " x20 ", y: (A_Index == 1 ? " y+9 " : " y+21 ") })),
        SharedClips(App, sendToSharedClips)
    )
}