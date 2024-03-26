#Include "./PM_App.ahk"

class ProfileModifyNew {
    static name := "Profile Modify New"
    static title := "Flow Mode - " . this.name
    static popupTitle := "ClipFlow - " . this.name

    static USE(App) {
        PM_App(App, this.popupTitle)
    }
}