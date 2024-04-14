#Include "./PMN_App.ahk"

class ProfileModifyNext {
    static name := "Profile Modify Next"
    static title := "Flow Mode - " . this.name
    static popupTitle := "ClipFlow - " . this.name
    static identifier := "04047fce826f48f751891b4721f7ac70" ; MD5 hash: ProfileModifyNext
    static dbSetting := {
        main: "\\10.0.2.13\fd\19-个人文件夹\HC\Software - 软件及脚本\AHK_Scripts\ClipFlow" . "\src\ActionModules\ProfileModifyNext\GuestProfiles",
        ; backup: A_MyDocuments . "\GuestProfiles",
        cleanPeriod: 182
    }
    static db := useFileDB(this.dbSetting)

    static USE(App) {
        PMN_App(App, this.title, this.db, this.identifier)
    }
}