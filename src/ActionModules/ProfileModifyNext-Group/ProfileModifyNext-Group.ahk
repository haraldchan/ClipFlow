#Include "PMNG_App.ahk"

class ProfileModifyNext_Group {
    static name := "ProfileModifyNext Group"
    static title := "Flow Mode - " . this.name
    static popupTitle := "ClipFlow - " . this.name

    static USE(App) {
        dbConfig := CONFIG.read("dbConfig")
        this.db := useFileDB({
            main: dbConfig["host"] . "\" . dbConfig["main"],
            archive: dbConfig["host"] . "\" . dbConfig["archive"],
            backup: dbConfig["host"] . "\" . dbConfig["backup"],
        })

        PMNG_App(App, this.title, this.db)
    }
}
