#Include "./JSnippets.ahk"

class BC_Execute {
	static JSnippet := "
	(
		const guestIds = {1}
		const queryInput = document.querySelector('input[placeholder="请输入查询条件"]')
		const querySelect = document.querySelector('input[placeholder="请选择字段"]')

		const change = new Event('input', {
			bubbles: true,
			cancelable: true,
		})

		function findSpan(label) {
			return Array.from(document.querySelectorAll('span')).find((span) => span.innerText === label)
		}

		document.querySelectorAll('.el-select-dropdown__item')[3].click()
		const queryBtn = findSpan('查 询')
		let okBtn, cxlBtn

		let coBtn = findSpan('退房')
		coBtn.click()

		setTimeout(() => {
			okBtn = Array.from(document.querySelector('.el-message-box__btns').querySelectorAll('span')).find((span) => span.innerText === '确定')
			cxlBtn = Array.from(document.querySelector('.el-message-box__btns').querySelectorAll('span')).find((span) => span.innerText === '取消')
			cxlBtn.click()
		}, 500)

		guestIds.forEach(id => {
			coBtn = findSpan('退房')

			setTimeout(() => {
				setTimeout(() => {
					queryInput.value = id
					queryInput.dispatchEvent(change)
					queryBtn.click()
				}, 1000);

				setTimeout(() => {
					coBtn.click()
					}, 2000);
					
				setTimeout(() => {
					okBtn.click()	
				}, 4000);

			}, 2000);
		})

		alert('已完成退房。')
	)"

	static checkoutBatch(ids) {
		WinActivate "ahk_class 360se6_Frame"
		WinSetAlwaysOnTop true, "ahk_class 360se6_Frame"
		; BlockInput true

		Send "^+j"
		Sleep 1000

		A_Clipboard := Format(this.JSnippet, JSON.stringify(ids))
		Send "^v"
		Sleep 1000
		Send "{Enter}"

		; BlockInput false
		WinSetAlwaysOnTop false, "ahk_class 360se6_Frame"
	}
}