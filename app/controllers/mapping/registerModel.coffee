mongoose = require('mongoose')
Schema = mongoose.Schema
_ = require('lodash')
config = process.g.config
utils = process.g.utils


module.exports = (sModelName, oSchema)->
	oSchema.timestamp = Date
	schema = new Schema(oSchema)
	mongoose.model(sModelName, schema)