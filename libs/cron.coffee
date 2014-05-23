path = require('path')
CronJob = require('cron').CronJob
request = require('request')
config = process.g.config
utils = process.g.utils
storage = utils.getCtrl('storage')

if config.STORAGE.cron
	store = new CronJob(config.STORAGE.cron, ()->
		storage.start()
	null, true, 'Asia/Shanghai')

