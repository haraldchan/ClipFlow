// inject
const queryInput = document.querySelector('input[placeholder="请输入查询条件"]')
const querySelect = document.querySelector('input[placeholder="请选择字段"]')

const change = new Event('input', {
	bubbles: true,
	cancelable: true,
})

document.querySelectorAll('.el-select-dropdown__item')[3].click()
const queryBtn = Array.from(document.querySelectorAll('span')).find((span) => span.innerText === '查 询').parentElement
let coBtn = Array.from(document.querySelectorAll('span')).find((span) => span.innerText === '退房')
let okBtn, cxlBtn

coBtn.click()
setTimeout(() => {
	okBtn = Array.from(document.querySelector('.el-message-box__btns').querySelectorAll('span')).find((span) => span.innerText === '确定')
	cxlBtn = Array.from(document.querySelector('.el-message-box__btns').querySelectorAll('span')).find((span) => span.innerText === '取消')
	cxlBtn.click()
}, 500)

// search
queryInput.value = '{idNumber}'
queryInput.dispatchEvent(change)
queryBtn.click()

// confirm checkout
coBtn = Array.from(document.querySelectorAll('span')).find((span) => span.innerText === '退房')
coBtn.click()
okBtn.click()



// batch check in 
// perhaps I should embbed this to ProfileClipper extension?
function findSpan(label){
	return Array.from(document.querySelectorAll('span')).find((span) => span.innerText === label)
}

// TODO: use setTimeout might not be a good idea, maybe use check display classes of something
const batchCheckin = setInterval(() => {
	findSpan('修改').click()
	findSpan('上报(R)').click()
	
	if (findSpan('一同入住')) {
		findSpan('一同入住').click()
	}

	if (findSpan('暂无数据')) {
		console.log('done.')
		clearInterval(batchCheckin)
	}
}, 2000);