class JSnippets {
	static getElements := "
	(
		const queryInput = document.querySelector('input[placeholder="请输入查询条件"]')
		const change = new Event('input')
		change.initEvent('input', true, true)
		change.eventType = 'message'

		const queryBtn = Array.from(document.querySelectorAll('span')).find(span => span.innerText === '查 询').parentElement
		let coBtn = Array.from(document.querySelectorAll('span')).find(span => span.innerText === '退房')
		let okBtn, cxlBtn

		coBtn.click()
			setTimeout(() => {
				okBtn = Array.from(document.querySelector('.el-message-box__btns').querySelectorAll('span')).find(span => span.innerText === '确定')
				cxlBtn = Array.from(document.querySelector('.el-message-box__btns').querySelectorAll('span')).find(span => span.innerText === '取消')
				cxlBtn.click()
			},500)
	)"

	static clickSearchBtn := "
	(
		queryInput.value = {1}
		queryInput.dispatchEvent(change)
		queryBtn.click()
	)"

	static clickCheckoutSpan := "
	(
		coBtn = Array.from(document.querySelectorAll('span')).find(span => span.innerText === '退房')
		coBtn.click()
	)"
}