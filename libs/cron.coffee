path = require('path')
storage = require(path.join(process.g.controllersPath, 'mapping', 'storage'))
CronJob = require('cron').CronJob
request = require('request')

# backup = new CronJob('*/2 * * * * *', ()->
# 	timestamp = (new Date()).getTime()
# 	request.get('http://127.0.0.1:8001?_type=openLogin&timestamp=' + timestamp + '&openID=12345')
# null, true, 'Asia/Shanghai')

store = new CronJob('* */10 * * * *', ()->
	storage((err)->
		if err
			console.log err
	)
null, true, 'Asia/Shanghai')