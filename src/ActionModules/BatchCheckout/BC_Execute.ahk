#Include "./JSnippets.ahk"

class BC_Execute {
	static inject() {
		A_Clipboard := JSnippets.getElements
		Send "^v"
		Sleep 100
		Send "{Enter}"
		Sleep 1000
	}

	static checkoutOne(id) {
		A_Clipboard := Format(JSnippets.clickSearchBtn, id)
		Send "^v"
		Sleep 100
		Send "{Enter}"
		Sleep 100

		Sleep 1000

		A_Clipboard := JSnippets.clickCheckoutSpan
		Send "^v"
		Sleep 100
		Send "{Enter}"
		Sleep 100
		Send "{Text}okBtn.click()"
		Sleep 100
		Send "{Enter}"
		Sleep 2000
	}

	static checkoutBatch(ids) {
		WinActivate "ahk_class 360se6_Frame"
		WinSetAlwaysOnTop true, "ahk_class 360se6_Frame"
		BlockInput true

		Send "^+j"
		Sleep 1000

		this.inject()

		for id in ids {
			this.checkoutOne(id)
		}

		BlockInput false
		WinSetAlwaysOnTop false, "ahk_class 360se6_Frame"
		MsgBox("已完成批量退房。", "Batch Checkout", "4096 T3")
	}
}