#Include "./RH_App.ahk"

class ReservationHandler {
    static name := "Reservation Handler"
    static title := "Flow Mode - " . this.name
    static popupTitle := "ClipFlow - " . this.name
    static identifier := "031709eafc20ab898d6b9e9860d31966" ; MD5 hash: ReservationHandler

    static USE(App) {
        RH_App(App, this.title, this.identifier)
    }
}