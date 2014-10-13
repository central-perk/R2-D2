_ = require('lodash')

config = process.g.config
utils = process.g.utils
filePath = process.g.path

eventRestart = null

module.exports = {
	index: (req, res)->
		res.render('index')
	restart: (req, res)->
		eventRestart = setTimeout(()->
			utils.restart()
		, 10000)
		res.successMsg('服务将在10秒后重启')
	cancelRestart: (req, res)->
		clearTimeout(eventRestart)
		res.successMsg('重启服务已被取消')
}