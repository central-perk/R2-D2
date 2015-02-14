env             = process.env.NODE_ENV or 'dev'
express         = require('express')
compression     = require('compression')
cookieParser    = require('cookie-parser')
bodyParser      = require('body-parser')
session         = require('express-session')
mongoStore      = require('connect-mongo')(session)
methodOverride  = require('method-override')
serveStatic     = require('serve-static')
favicon         = require('serve-favicon')
errorHandler    = require('errorhandler')
logger          = require('morgan')
multer          = require('multer')
hbs             = require('hbs')
basicAuth       = require('connect-basic-auth')

config = process.g.config
utils = process.g.utils
filePath = process.g.path
APP_CONFIG = config.APP
BASC_AUTH_CONFIG = APP_CONFIG.BASC_AUTH

module.exports = (app, passport, mongoose)->
	# 开发环境
	if app.get('env') == 'dev'
		app.use(errorHandler())
		app.use(logger('dev')) # 纪录每一个请求
	# 生产环境
	# if app.get('env') == 'pro'
		# return


	# res的中间件
	app.use (req, res, next)->
		res.success = (data)->
			res.json(data)
		res.successMsg = (data)->
			res.json({msg: data})
		res.errorMsg = (data)->
			res.status(500).json({msg: data})
		# res.error = (data)->
		#     res.status(500).json({
		#         # code: 400,
		#         msg: data
		#     })
		next()

	# 所有环境

	app.set('port', APP_CONFIG.PORT)
	app.set('views', path.join(filePath.pub, 'views'))

	app.set('view engine', 'html')
	app.engine('html', hbs.__express)
	hbs.registerPartials(path.join(filePath.pub, 'views', 'partials'))
	app.enable('jsonp callback')


	# basicAuth
	app.use(basicAuth((credentials, req, res, next)->
		if credentials and credentials.username == BASC_AUTH_CONFIG.username and credentials.password == BASC_AUTH_CONFIG.password
			next();
		else
			next("Unautherized!")
		)
	)

	# compress requests and responses
	app.use(compression()) # 需要进一步设置
	app.use(cookieParser())
	app.use(bodyParser.urlencoded({extended: true}))
	app.use(bodyParser.json())
	app.use(methodOverride());
	app.use(serveStatic(filePath.pub)) # 可以设置多个静态目录

	app.use(session({
		resave: true,
		saveUninitialized: true,
		secret: APP_CONFIG.SESSION.secret,
		store: new mongoStore({
			db : mongoose.connection.db,
			collection: APP_CONFIG.SESSION.collection
		}),
		cookie: APP_CONFIG.COOKIE,
		key: 'ex_mean_sid'
	}))
	# 必须放在cookieParser和session后面
	app.use(passport.initialize())
	app.use(passport.session())

	app.use(multer())