#Include "./PMN_App.ahk"

class ProfileModifyNext {
    static name := "ProfileModifyNext"
    static title := "Flow Mode - " . this.name
    static popupTitle := "ClipFlow - " . this.name
    static identifier := "04047fce826f48f751891b4721f7ac70" ; MD5 hash: ProfileModifyNext
    static dbSetting := {
        main: A_ScriptDir . "\src\ActionModules\ProfileModifyNext\GuestProfiles",
        backup: "\\10.0.2.13\fd\19-个人文件夹\HC\Software - 软件及脚本\GuestProfilesBackup",
    }
    static fdb := useFileDB(this.dbSetting)
    static db := useDateBase(this.dbSetting)

    static USE(App) {
        today := Format(A_Now, "yyyyMMdd")
        yesterday := FormatTime(DateAdd(today, -1, "Days"), "yyyyMMdd")

        if (!FileExist(this.db.archive . "\" . yesterday . " - archive.json")) {
            this.fdb.createArchive(yesterday)
            this.fdb.createArchiveBackup(yesterday)
        }

        if (!FileExist(this.db.backup . "\" . SubStr(yesterday, 1, 6) . "\" . yesterday . "_backup.json")) {
            this.db.createBackup(yesterday)
        }
        
        PMN_App(App, this.title, this.fdb, this.db, this.identifier)
    }
}