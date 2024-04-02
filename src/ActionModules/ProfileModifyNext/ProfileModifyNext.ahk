#Include "./PMN_App.ahk"

class ProfileModifyNext {
    static name := "Profile Modify Next"
    static title := "Flow Mode - " . this.name
    static popupTitle := "ClipFlow - " . this.name
    static db := {
        centralPath: "",
        localPath: ""
    }

    static USE(App) {
        PMN_App(App, this.popupTitle, this.db)
    }
}