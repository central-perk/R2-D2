path = require('path')
fs = require('fs-extra')
_  = require('lodash')
async = require('async')
mongoose = require('mongoose')

config = process.g.config
utils = process.g.utils
auth = utils.getCtrl('auth')
logModel = utils.getCtrl('logModel')
viewsPath = process.g.viewsPath

PERPAGE = config.PERPAGE


fListAM = (callback)->
	async.auto({
		aAuth: (cb)->
			auth._listAll(cb)
		aLogModels: (cb)->
			logModel._listAll(cb)
	}, callback)

module.exports = {
	index: (req, res)->
		nav = config.BACK.nav # 静态导航
		fListAM((err, oListAM)->
			aDynamicNav = []
			if !err
				aAuth = oListAM.aAuth
				aLogModels = oListAM.aLogModels
				_.each(aAuth, (oAuth)->
					temp = {
						title: oAuth.appName
						href: oAuth.appID
					}
					if aLogModels.length
						temp.sub = []
					_.each(aLogModels, (oLogModel)->
						if oLogModel.appID == oAuth.appID
							temp.sub.push({
								title: oLogModel.type
								href: "#{oAuth.appID}.#{oLogModel.type}"
							})
					)
					aDynamicNav.push(temp)
				)
			# nav = nav.concat(aDynamicNav)
			res.render('back/index.html', {nav, dnav:aDynamicNav})			
		)
	getContent: (req, res)->
		module = req.params['module']
		switch module
			when 'auth'
				auth._listAll((err, aAuthList)->
					res.render('back/auth.html', {aAuthList})
				)
			when 'logmodel'
				aLogModelsList = []
				fListAM((err, oListAM)->
					if !err
						aAuth = oListAM.aAuth
						aLogModels = oListAM.aLogModels
						_.each(aAuth, (oAuth)->
							_.each(aLogModels, (oLogModel)->
								if oAuth.appID == oLogModel.appID
									aLogModelsList.push({
										appName: oAuth.appName,
										appID: oAuth.appID,
										token: oAuth.token,
										type: oLogModel.type,
										ts: oLogModel.ts
									})
							)
						)
					aAttrValue = logModel._listAttrValue()
					res.render('back/logmodel.html', {aLogModelsList, aAuth, aLogModels, aAttrValue})
				)
			else
				appID = module.split('.')[0]
				sLogType = module.split('.')[1]
				page = (if req.param('page')  > 0 then req.param('page') else 1) - 1
				try
					Model = mongoose.model(module)
					async.auto({
						getOneAuth: (cb)->
							auth._getOne({appID}, cb)
						getOneModel: (cb)->
							logModel._getOne({appID, type: sLogType}, cb)
						getLogs: (cb)->
							Model.find({}, '-__v -_id -fileName') # 在logger服务器没有必要给出__v 和 _id
								.sort({ts: -1})
								.skip(PERPAGE * page)
								.limit(PERPAGE)
								.exec(cb)
						pageAmount: (cb)->
							Model.count({}, (err, num)->
								pages = Math.floor(num / PERPAGE) + 1
								cb(err, pages)
							)
					}, (err, results)->
						if !err
							oAuth = results.getOneAuth
							oLogModel = results.getOneModel
							nPageAmount = results.pageAmount
							_aLogs = results.getLogs

							aLogKeys = _.reduce(oLogModel.attributes, (arr, attr)->
								arr.push(attr.key)
								return arr
							,[])
							aLogKeys.push('ts')

							token = oAuth.token
							ts = oLogModel.ts
							url = "/?type=#{sLogType}&appID=#{appID}"
							url += "&token=#{token}&ts={{Date.getTime()}}"
							_.each(oLogModel.attributes, (oAttr)->
								url += "&#{oAttr.key}={{#{oAttr.value}}}"
							)

							if _aLogs.length
								aLogs = []
								_.each(_aLogs, (oLog)->
									temp = {}
									_.each(aLogKeys, (sLogkey)->
										temp[sLogkey] = oLog[sLogkey] || ''
									)
									aLogs.push(temp)
								)
								temp = {
									url,
									appID,
									type: sLogType,
									ts,
									aLogs,
									aLogKeys,
									nPageAmount,
									page: page + 1
								}
							else
								temp = {
									url,
									appID,
									type: sLogType,
									ts
								}
							res.render('back/apps.html', temp)
						else
							res.render('授权信息出错了!')
					)
				catch e
					res.send('日志模型不存在!')

		# else
		# 	appID = module
		# 	async.auto({
		# 		getModels: (cb)->
		# 			logModel._get({appID}, cb)
		# 		getAuth: (cb)->
		# 			auth._getOne({appID}, cb)
		# 	}, (err, results)->
		# 		if !err
		# 			aLogModels = results.getModels
		# 			oAuth = results.getAuth
		# 			token = oAuth.token
		# 			temp = []
		# 			_.each(aLogModels, (oLogModels)->
		# 				url = "/?type=#{oLogModels.type}&appID=#{oLogModels.appID}"
		# 				url += "&token=#{token}&ts={{Date.getTime()}}"
		# 				_.each(oLogModels.attributes, (oAttr)->
		# 					url += "&#{oAttr.key}={{#{oAttr.value}}}"
		# 				)
		# 				temp.push({
		# 					url,
		# 					appID: oLogModels.appID,
		# 					type: oLogModels.type,
		# 					ts: oLogModels.ts
		# 				})
		# 			)
		# 			if temp.length == 0
		# 				res.send('赶紧去创建日志模型吧！')	
		# 			else
		# 				res.render('back/apps.html', temp)

		# 		else
		# 			res.send('授权信息出错了!')
		# 	)
}