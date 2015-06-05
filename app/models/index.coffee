fs 			= require('fs')
path 		= require('path')
_ 			= require('lodash')
mongoose 	= require('mongoose')
Schema 		= mongoose.Schema

config 		= process.g.config
utils 		= process.g.utils
filePath 	= process.g.path

modelConfigPath = path.join(__dirname, 'config')
modelMappingPath = path.join(__dirname, 'mapping')

# 注册静态模型
_.forEach fs.readdirSync(modelMappingPath), (modelFileName, index)->
	modelName = modelFileName.replace('.js', '')
	require(path.join(modelMappingPath, modelFileName))
	module.exports[modelName] = mongoose.model(modelName)