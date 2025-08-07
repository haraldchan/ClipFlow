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
    static fdb := useFileDB(this.dbSetting)
    static db := useDateBase(this.dbSetting)
    static testers := [
        ; "4CE325BJNW", 
        ; "4CE325BJS4", 
        ; "4CE325BJRC"
    ]

    static USE(App) {
        if (!FileExist(this.fdb.archive . "\" . A_Now.yesterday() . " - archive.json")) {
            this.fdb.createArchive(A_Now.yesterday())
        }
        
        if (!FileExist(this.db.backup . "\" . SubStr(A_Now.yesterday(), 1, 6) . "\" . A_Now.yesterday() . " - backup.json")) {
            this.fdb.createArchiveBackup(A_Now.yesterday())
        }

        ; if (!FileExist(this.db.backup . "\" . SubStr(yesterday, 1, 6) . "\" . yesterday . "_backup.json")) {
        ;     this.db.createBackup({ 
        ;         path: this.db.main . "\" . SubStr(yesterday, 1, 6) . "\" . yesterday . ".json",
        ;         filename: yesterday
        ;     })
        ; }
        
        PMN_App(App, this.title, this.fdb, this.db, this.identifier)
    }
}