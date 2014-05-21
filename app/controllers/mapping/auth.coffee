crypto = require('crypto')
authDao = require(process.g.daoPath).auth

fMd5 = (text)->
	crypto.createHash('md5').update(text).digest('hex')

# token的生成下次放到model中
fToken = (appName, appID)->
	nRandom = Math.random()
	text = appID + nRandom + appName
	fMd5(text)



module.exports = {
	create: (req, res)->
		appName = req.body.appName
		authDao.getOne({appName}, (err, auth)->
			if !auth
				authDao.count({}, (err, amount)->
					appID = Number(amount) + 1
					token = fToken(appName, appID)
					authDao.create({appName, appID, token}, (err, raw)->
						if !err
							res.requestSucceed({appID, token})
						else
							res.requestError('授权失败')
					)
				)
			else
				res.requestError('appName已存在')
		)
	get: (query, callback)->
		authDao.getOne(query, callback)
}