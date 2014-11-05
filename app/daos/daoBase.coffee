_ = require('lodash')

DaoBase = (()->
	instance = []
	update_option = {
		upsert: true
	}

	handleErr = (err, document, callback)->
		if !err
			callback(null, document)
		else
			console.log(err)
			errMsg = null
			_.forEach(err.errors, (fieldValue, field)->
				errMsg = errMsg or fieldValue.message
			)
			callback(errMsg)
	constructor = (Model)->
		return {
			Model: Model,
			deleteByID: (id, callback)->
				this.delete({_id: id}, callback)
			updateByID: (id, doc, callback)->
				this.update({_id: id}, doc, callback)
			getByID: (id, callback)->
				this.getOne({_id: id}, callback)
			create: (doc, callback)->
				Model.create(doc, (err, raw)->
					handleErr(err, raw, callback)
				)
			delete: (query, callback)->
				Model.remove(query, (err, numberAffected)->
					if numberAffected
						handleErr(err, numberAffected, callback)
					else
						handleErr('元素不存在', numberAffected, callback)
				)
			update: (query, doc, callback)->
				delete doc._id
				Model.update(query, doc, update_option, (err, numberAffected, raw)->
					handleErr(err, numberAffected, callback)
				)
			get: (query, callback)->
				Model.find(query, (err, docs)->
					handleErr(err, docs, callback)
				)
			getOne: (query, callback)->
				Model.findOne(query, (err, docs)->
					handleErr(err, docs, callback)
				)
			listAll: (callback)->
				this.get({}, callback)
			count: (query, callback)->
				Model.count(query, (err, number)->
					handleErr(err, number, callback)
				)
			list: (criteria, sort, callback)->
				query = criteria.query || {}
				options = criteria.options
				Model.find(query)
					.sort(sort)
					.limit(options.perPage)
					.skip(options.perPage * options.page)
					.exec(callback)
			listPopulate: (criteria, sort, populates, callback)->
				query = criteria.query || {}
				populates = populates.split(' ')
				temp = Model.find(query)
				_.each(populates, (populate, index)->
					temp = temp.populate(populate)
				)
				temp.sort(sort)
					.limit(options.perPage)
					.skip(options.perPage * options.page)
					.exec(callback)
			listPopulateOne: (query, populates, callback)->
				populates = populates.split(' ')
				temp = Model.find(query)
				_.each(populates, (populate, index)->
					temp = temp.populate(populate)
				)
				temp.exec(callback)
			listPopulateAll: (criteria, sort, callback)->
				query = criteria.query || {}
				populates = populates.split(' ')
				temp = Model.find(query)
				_.each(populates, (populate, index)->
					temp = temp.populate(populate)
				)
				temp.sort(sort)
					.exec(callback)
		}
	return {
		getInstance: (Model)->
			modelName = Model.collection.name
			if _.indexOf(instance, modelName) == -1
				instance.push(modelName)
			return constructor(Model)
	}
)()

module.exports = DaoBase