LocalStrategy = require('passport-local').Strategy

module.exports = (passport)->
	passport.serializeUser (user, done)-> # 保存user对象	
		done(null, user) # 可以通过数据库方式操作
	passport.deserializeUser (user, done)->
		done(null, user)