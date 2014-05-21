path = require('path')
storage = require(path.join(process.g.controllersPath, 'mapping', 'storage'))
CronJob = require('cron').CronJob
request = require('request')
config = process.g.config
# backup = new CronJob('*/2 * * * * *', ()->
# 	timestamp = (new Date()).getTime()
# 	request.get('http://127.0.0.1:8001?_type=openLogin&timestamp=' + timestamp + '&openID=12345')
# null, true, 'Asia/Shanghai')

# store = new CronJob(config.STORAGE_CRON, ()->
# 	storage((err)->
# 		if err
# 			console.log err
# 	)
# null, true, 'Asia/Shanghai')


# job1 = new CronJob({
#   cronTime: '25 10 15 * * *'
#   onTick: ()->
#   	console.log 'ccc'
#   onComplete: ()->
#   	console.log this
#   	job1.stop()
#   	console.log this

#   start: true
#   timeZone: 'Asia/Shanghai'
# });


# console.log job1

# job2 = new CronJob({
#   cronTime: '30 10 15 * * *'
#   onTick: ()->
#   	job1.stop()
#   	console.log job1
#   start: true
#   timeZone: 'Asia/Shanghai'
# });




