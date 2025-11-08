#Include "PMNG_App.ahk"

class ProfileModifyNext_Group {
    static name := "ProfileModifyNext Group"
    static title := "Flow Mode - " . this.name
    static popupTitle := "ClipFlow - " . this.name

    static USE(App) {
        this.dbSettings := CONFIG.read("dbSettings")
        this.db := useFileDB(this.dbSettings)

        PMNG_App(App, this.title, this.db)
    }
}
