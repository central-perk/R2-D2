path = require('path')
CronJob = require('cron').CronJob
request = require('request')
config = process.g.config
utils = process.g.utils
storage = utils.getCtrl('storage')
logFile = utils.getCtrl('log')



delay3s = ((new Date()).getSeconds() + 3) % 60

# cron = "#{delay3s} * * * * *"
# if config.STORAGE.cron
# 	store = new CronJob(cron, ()->
# 		storage.start()
# 	null, true, 'Asia/Shanghai')

# 定时入库
if config.STORAGE.cron
	store = new CronJob(config.STORAGE.cron, ()->
		logFile.readyStorage((err)-> # 将当前现有的文件标记成可入库
			if !err
				storage.start()
			else
				console.log err
		)
	null, true, 'Asia/Shanghai')