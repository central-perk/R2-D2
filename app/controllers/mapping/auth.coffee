crypto = require('crypto')
_ = require('lodash')
config = process.g.config
AUTH_STATUS = config.STATUS.AUTH
authDao = require(process.g.daoPath).auth


fMd5 = (text)->
	crypto.createHash('md5').update(text).digest('hex')

# appID和token的生成互相独立
createToken = (appName)->
	nRandom = Math.random()
	text = appName + nRandom
	fMd5(text)

createAppID = (appName)->
	createToken(appName).slice(0, 6)



module.exports = {
	# 外部接口
	create: (req, res)->
		appName = req.body.appName
		authDao.getOne({appName}, (err, auth)->
			if !auth
				appID = createAppID(appName)
				token = createToken(appName)
				authDao.getOne({appID}, (err, auth)-> # appID不能重复
					if !auth
						authDao.create({appName, appID, token}, (err, raw)->
							if !err
								# res.requestSucceed({appName, appID, token})
								res.requestSucceed('应用授权成功')
							else
								res.requestError('应用授权失败')
						)
					else # appID重复，概率很低
						module.exports['create'](req, res)
				)
			else
				appID = auth.appID
				token = auth.token
				# res.requestSucceed({appName, appID, token})
				res.requestError('应用已授权')
		)
	list: (req, res)->
		criteria = {
			query: {
				status: AUTH_STATUS.enable
			}
		}
		authDao.list(criteria, {ts: -1}, (err, auths)->
			if !err
				aAuth = []
				_.each(auths, (auth)->
					aAuth.push({
						appName: auth.appName,
						appID: auth.appID,
						token: auth.token,
						ts: auth.ts,
						status: auth.status
					})
				)
				res.requestSucceed(aAuth)
			else
				res.requestError('授权列表获取失败')
		)
	# 内部接口
	listAuth: (callback)->
		authDao.listAll((err, auths)->
			aAuth = []
			if !err
				_.each(auths, (auth)->
					aAuth.push({
						appName: auth.appName,
						appID: auth.appID,
						token: auth.token,
						ts: auth.ts,
						status: auth.status
					})
				)
			callback(err, aAuth)			
		)
	checkAuth: (query, callback)->
		appID = query.appID
		token = query.token
		authDao.getOne({appID, token}, (err, auth)->
			bAuthorized = if auth then true else false
			callback(err, bAuthorized)
		)
}