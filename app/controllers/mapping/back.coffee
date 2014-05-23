path = require('path')
fs = require('fs-extra')
_  = require('lodash')

config = process.g.config
utils = process.g.utils
auth = utils.getCtrl('auth')

viewsPath = process.g.viewsPath

module.exports = {
	index: (req, res)->
		auth.listAuth((err, auths)->
			aDynamicNav = []
			nav = config.BACK.nav
			if !err
				_.each(auths, (auth)->
					aDynamicNav.push({
						name: auth.appID,
						title: auth.appName
					})
				)
			nav = nav.concat(aDynamicNav)
			res.render('back/index.html', {nav})
		)		
	getContent: (req, res)->
		module = req.params['module']
		# aStaticNav = _.reduce(config.BACK.nav, (arr, oNav)->
		# 	arr.push(oNav.name)
		# 	return arr
		# , [])
		if module == 'auth'
			auth.listAuth((err, oAuthList)->
				console.log oAuthList
				res.render('back/auth.html', {oAuthList})
			)

		# if _.indexOf(aStaticNav, module) != -1 # 静态目录
		# else # 动态目录

}