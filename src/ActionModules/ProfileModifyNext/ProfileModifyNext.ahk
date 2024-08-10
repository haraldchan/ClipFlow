#Include "./PMN_App.ahk"

class ProfileModifyNext {
    static name := "ProfileModifyNext"
    static title := "Flow Mode - " . this.name
    static popupTitle := "ClipFlow - " . this.name
    static identifier := "04047fce826f48f751891b4721f7ac70" ; MD5 hash: ProfileModifyNext
    static dbSetting := {
        main: "\\10.0.2.13\fd\19-个人文件夹\HC\Software - 软件及脚本\AHK_Scripts\ClipFlow" . "\src\ActionModules\ProfileModifyNext\GuestProfiles",
        ; backup: A_MyDocuments . "\GuestProfiles",
        cleanPeriod: 182,
        archive: "\\10.0.2.13\fd\19-个人文件夹\HC\Software - 软件及脚本\AHK_Scripts\ClipFlow" . "\src\ActionModules\ProfileModifyNext\GuestProfilesArchive"
    }
    static db := useFileDB(this.dbSetting)

    static USE(App) {
        today := Format(A_Now, "yyyyMMdd")
        yesterday := FormatTime(DateAdd(today, -1, "Days"), "yyyyMMdd")
        if (!FileExist(this.db.archive . "\" . yesterday . " - archive.json")) {
            this.db.createArchive(yesterday)
        }
        
        PMN_App(App, this.title, this.db, this.identifier)
    }
}