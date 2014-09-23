env = process.env.NODE_ENV or 'dev'
express = require('express')
basicAuth = require('connect-basic-auth')

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
        res.error = (data)-> 
            res.json({
                code: data.code || 400,
                msg: data
            })
        res.success = (data)->
            res.json({
                code: 200,
                msg: data
            })
        next()
    app.set('port', config.PORT)
    app.set('views', process.g.viewsPath)
    app.set('view engine', 'html')
    app.engine('html', require('hbs').__express)
    app.use(express.compress({
        filter: (req, res)->
            return (/json|text|javascript|css/).test(res.getHeader('Content-Type'))
        level: 9
    })) 
    app.use(basicAuth((credentials, req, res, next)->
        if credentials and credentials.username == "node" and credentials.password == "log"
            next();  
        else
            if !credentials
                console.log("credentials not provided");  
            if credentials and credentials.username
                console.log("credentials-username:" + credentials.username)
            if credentials and credentials.password
                console.log("credentials-password:" + credentials.username); 
            next("Unautherized!")
        )
    )

    app.use(express.json())
    app.use(express.urlencoded())
    app.use(require('connect-multiparty')())
    app.use(express.cookieParser())
    app.use(express.methodOverride())
    app.enable('jsonp callback')
    app.use(app.router)
    app.use(express.static(process.g.publicPath)) # 可以设置多个静态目录
    hbs = require('hbs')
    hbs.registerPartials(path.join(process.g.viewsPath, 'back', 'base'))
    hbs.registerHelper('trList', (items, options)->
        out = ''
        for item in items
            out += '<tr>'    
            for key, value of item
                out += '<td>' + value + '</td>'
            out += '</tr>'
        return out
    )


