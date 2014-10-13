modelName = path.basename(__filename, '.js')
Model = require('mongoose').model(modelName)

module.exports = {
	list: (query, options, callback)->
		Model.find(query, 'app name labelName attrs ts')
			.sort({ts: -1})
			.limit(options.perPage)
			.skip(options.perPage * options.page)
			.populate('app', '_id name token')
			.exec(callback)
}

