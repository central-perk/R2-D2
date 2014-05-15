path = require('path')
fs = require('fs-extra')
_ = require('lodash')
DaoBase = require(path.join(__dirname, 'DaoBase'))
models = require(process.g.modelsPath)


_.each(models, (model, index)->
	daoPath = path.join(__dirname, 'mapping', index + '.js')
	if fs.existsSync(daoPath)
		module.exports[index] = _.extend(DaoBase.getInstance(model), require(daoPath))
	else
		module.exports[index] = DaoBase.getInstance(model)
)