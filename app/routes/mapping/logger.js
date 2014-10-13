config = process.g.config
utils = process.g.utils
filePath = process.g.path

logger = utils.getCtrl('logger')

module.exports = function(app, mw, logger) {
	
	app.post('/upload/app/:appID/logname/:logName/token/:token', logger.create)

	app.get('/logger', logger.list)

}