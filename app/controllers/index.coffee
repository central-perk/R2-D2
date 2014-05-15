path = require('path')
fs = require('fs-extra')
_ = require('lodash')
ctrlsPath = path.join(__dirname, 'mapping')

_.each(fs.readdirSync(ctrlsPath), (ctrlFile, index)->
	if ~ctrlFile.indexOf '.js'
		ctrlName = ctrlFile.replace('.js', '')
		ctrlPath = path.join(ctrlsPath, ctrlFile)
		module.exports[ctrlName] = require(ctrlPath)
)