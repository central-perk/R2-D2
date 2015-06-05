modelName = path.basename(__filename, '.js')
Model = require('mongoose').model(modelName)

module.exports = {
	list: (query, options, callback)->
		Model.find(query, '_id name token status ts')
			.sort({ts: -1})
			.limit(options.perPage)
			.skip(options.perPage * options.page)
			.exec(callback)
}