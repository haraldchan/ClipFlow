#Include "./PMN_App.ahk"

class ProfileModifyNext {
    static name := "ProfileModifyNext"
    static title := "Flow Mode - " . this.name
    static popupTitle := "ClipFlow - " . this.name
    static identifier := "04047fce826f48f751891b4721f7ac70" ; MD5 hash: ProfileModifyNext
    static dbSetting := {
        main: A_ScriptDir . "\src\ActionModules\ProfileModifyNext\GuestProfiles",
        archive: A_ScriptDir . "\src\ActionModules\ProfileModifyNext\GuestProfilesArchive",
        backup: "\\10.0.2.13\fd\19-个人文件夹\HC\Software - 软件及脚本\GuestProfilesBackup",
    }
    static db := useFileDB(this.dbSetting)

    static USE(App) {
        yesterday := A_Now.yesterday().toFormat("yyyyMMdd")

        if (!FileExist(this.db.archive . "\" . yesterday . " - archive.json")) {
            this.db.createArchive(yesterday)
        }
        
        PMN_App(App, this.title, this.db, this.identifier)
    }
}
