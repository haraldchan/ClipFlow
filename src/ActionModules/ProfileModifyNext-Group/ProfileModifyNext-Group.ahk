#Requires AutoHotkey v2.0
#Include "PMNG_App.ahk"

class ProfileModifyNext_Group {
    static name := "rofileModifyNext Group"
    static title := "Flow Mode - " . this.name
    static popupTitle := "ClipFlow - " . this.name
    static dbSetting := {
        main: "\\10.0.2.13\fd\19-个人文件夹\HC\Software - 软件及脚本\AHK_Scripts\ClipFlow" . "\src\ActionModules\ProfileModifyNext\GuestProfiles",
        ; backup: A_MyDocuments . "\GuestProfiles",
        cleanPeriod: 182,
        archive: "\\10.0.2.13\fd\19-个人文件夹\HC\Software - 软件及脚本\AHK_Scripts\ClipFlow" . "\src\ActionModules\ProfileModifyNext\GuestProfilesArchive"
    }
    static db := useFileDB(this.dbSetting)

    static USE(App) {
        PMNG_App(App, this.title, this.db)
    }
}
