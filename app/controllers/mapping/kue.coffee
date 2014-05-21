kue = require('kue')
jobs = kue.createQueue()
utils = process.g.utils
logger = utils.getCtrl('log')

aDataModels = _.keys(require('mongoose').models)

_.each(aDataModels, (sDateModel)->
	jobs.process(sDateModel, 1, (job, done)->
		sLogType = job.data.type
		oLog = job.data.log
		logger(sLogType, (err, fWriteLog)->
			fWriteLog(oLog, (err)->
				if !err
					done()
			)			
		)

		# fWriteLog = new logger(sLogType)
		# fWriteLog(oLog, (err)->
		# 	if !err
		# 		done()
		# )
	)		
)

module.exports = (req)->
	type = req.type
	log = req.query
	jobs.create(type, {type,log}).attempts(3).save()



