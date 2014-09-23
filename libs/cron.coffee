path = require('path')
CronJob = require('cron').CronJob
request = require('request')
config = process.g.config
utils = process.g.utils
storage = utils.getCtrl('storage')


delay3s = ((new Date()).getSeconds() + 3) % 60

cron = "#{delay3s} * * * * *"
if config.STORAGE.cron
	store = new CronJob(cron, ()->
		storage.start()
	null, true, 'Asia/Shanghai')

