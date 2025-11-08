#Include "./PMN_App.ahk"

class ProfileModifyNext {
    static name := "ProfileModifyNext"
    static title := "Flow Mode - " . this.name
    static popupTitle := "ClipFlow - " . this.name
    static identifier := "04047fce826f48f751891b4721f7ac70" ; MD5 hash: ProfileModifyNext

    static USE(App) {
        this.dbSettings := CONFIG.read("dbSettings")
        this.db := useFileDB(this.dbSettings)

        yesterday := A_Now.yesterday().toFormat("yyyyMMdd")

        if (!FileExist(this.db.archive . "\" . yesterday . " - archive.json")) {
            this.db.createArchive(yesterday)
        }
        
        PMN_App(App, this.title, this.db, this.identifier)
    }
}
