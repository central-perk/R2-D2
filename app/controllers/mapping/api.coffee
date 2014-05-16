path = require('path')
fs = require('fs-extra')
markdown = require('markdown-js')
config = process.g.config
viewsPath = process.g.viewsPath

module.exports = {
	index: (req, res)->
		res.render('api/index.html', {nav: config.API.nav})
	getContent: (req, res)->
		module = req.params['module']
		tplPath = path.join(viewsPath, 'api', 'tpl', module + '.md')
		fs.exists(tplPath, (exists)->
			if exists
				content = fs.readFileSync(tplPath, 'utf-8')

				html_content = markdown.parse(content)
				# html_content = markdown.toHTML(content)
				res.send(html_content)
			else
				res.send('tpl not exist')
		)
}