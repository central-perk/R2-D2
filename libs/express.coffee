env = process.env.NODE_ENV or 'dev'
express = require('express')

config = process.g.config

module.exports = (app, mongoose)->
    # 开发环境
    if app.get('env') == 'dev'
        app.use(express.errorHandler())
        app.set('view cache', false)
        app.use(express.logger('dev')) # 纪录每一个请求，仅在开发环境下
    # 生产环境
    # if app.get('env') == 'pro'
        # return

    # 所有环境

    # res的中间件
    app.use (req,res,next)->
        res.requestError = (data)-> 
            res.json({
                status: 0,
                message: data
            })
        res.requestSucceed = (data)->
            res.json({
                status: 1,
                message: data
            })
        next()
    app.set('port', config.PORT)
    app.use(express.compress({
        filter: (req, res)->
            return (/json|text|javascript|css/).test(res.getHeader('Content-Type'))
        level: 9
    })) 
    app.use(express.json())
    app.use(express.urlencoded())
    app.use(require('connect-multiparty')())
    app.use(express.cookieParser())
    app.use(express.methodOverride())
    app.enable('jsonp callback')
    app.use(app.router)