#Include "./PMN_App.ahk"

class ProfileModifyNext {
    static name := "Profile Modify Next"
    static title := "Flow Mode - " . this.name
    static popupTitle := "ClipFlow - " . this.name
    static identifier := "04047fce826f48f751891b4721f7ac70" ; MD5 hash: ProfileModifyNext

    static db := {
        centralPath: A_ScriptDir . "\src\ActionModules\ProfileModifyNext\GuestProfiles",
        localPath: ""
    }

    static USE(App) {
        PMN_App(App, this.popupTitle, this.db)
    }
}