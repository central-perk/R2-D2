fs = require('fs')
path = require('path')
_ = require('lodash')
mongoose = require('mongoose')

modelsPath = path.join(__dirname , 'mapping')

_.each(fs.readdirSync(modelsPath), (file, index)->
	require(path.join(modelsPath, file))
	modelName = file.replace('.js', '');
	module.exports[modelName] = mongoose.model(modelName)
	return
)

