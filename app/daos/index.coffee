path 	= require('path')
fs 		= require('fs-extra')
_ 		= require('lodash')

config 	= process.g.config
utils 	= process.g.utils
filePath = process.g.path

daosPath = path.join(filePath.daos, 'mapping')
daoBase = require(path.join(__dirname, 'daoBase'))
models = require(filePath.models)

_.forEach(models, (Model, modelName)->
	modelFileName = modelName + '.js'
	daoFilePath = path.join(daosPath, modelFileName)
	if fs.existsSync(daoFilePath)
		module.exports[modelName] = _.extend(daoBase.getInstance(Model), require(daoFilePath))
	else
		module.exports[modelName] = daoBase.getInstance(Model)
)