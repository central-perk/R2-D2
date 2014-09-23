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
								title: oLogModel.cname
								href: "#{oAuth.appID}.#{oLogModel.name}"
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
										name: oLogModel.name,
										cname: oLogModel.cname,
										ts: oLogModel.ts
									})
							)
						)
					aAttrValue = logModel._listAttrValue()
					res.render('back/logmodel.html', {aLogModelsList, aAuth, aLogModels, aAttrValue})
				)
			else
				sAppID = module.split('.')[0]
				sLogName = module.split('.')[1]
				nPage = (if req.param('page')  > 0 then req.param('page') else 1) - 1
				try
					Model = mongoose.model(module)
					async.auto({
						getOneAuth: (cb)->
							auth._getOne({appID: sAppID}, cb)
						getOneModel: (cb)->
							logModel._getOne({appID: sAppID, name: sLogName}, cb)
						getLogs: (cb)->
							Model.find({}, '-__v -_id -fileName') # 在logger服务器没有必要给出__v 和 _id
								.sort({ts: -1})
								.skip(PERPAGE * nPage)
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
							sLogCname = results.getOneModel.cname
							_aLogs = results.getLogs

							aLogAttr = _.reduce(oLogModel.attr, (arr, attr)->
								arr.push({
									name: attr.name,
									cname: attr.cname
								})
								return arr
							,[])
							aLogAttr.push({
								name: 'ts',
								cname: '时间'
							})
							aLogAttr.push({
								name: 'level',
								cname: '等级'
							})
							sToken = oAuth.token
							nTs = oLogModel.ts
							url = "/upload/app/#{sAppID}/logname/#{sLogName}/token/#{sToken}"
							if _aLogs.length
								aLogs = []
								_.each(_aLogs, (oLog)->
									temp = {}
									_.each(aLogAttr, (oAttr)->
										name = oAttr.name
										temp[name] = oLog[name] || ''
									)
									aLogs.push(temp)
								)
								temp = {
									url,
									appID: sAppID,
									name: sLogName,
									cname: sLogCname,
									ts: nTs,
									logs: aLogs,
									logAttr: aLogAttr,
									pageAmount: nPageAmount,
									page: nPage + 1
								}
							else
								temp = {
									url,
									appID: sAppID,
									name: sLogName,
									ts: nTs
								}
							res.render('back/apps.html', temp)
						else
							res.render('授权信息出错了!')
					)
				catch e
					console.log e
					res.send('日志模型不存在!')
}