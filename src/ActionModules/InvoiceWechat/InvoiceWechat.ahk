#Include "./IW_App.ahk"

class InvoiceWechat {
    static name := "Invoice Fill-in(Wechat)"
    static title := "Flow Mode - " . this.name
    static popupTitle := "ClipFlow - " . this.name

    static USE(App) {
        IW_App(App, popupTitle)
    }
}