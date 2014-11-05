path 	= require('path')
fs 		= require('fs-extra')
async 	= require('async')
mongoose = require('mongoose')

config = process.g.config
utils = process.g.utils
filePath = process.g.path

DB_CONFIG = config.APP.DB

dbHost = "mongodb://#{DB_CONFIG.host}:#{DB_CONFIG.port}/#{DB_CONFIG.name}_#{process.env.NODE_ENV}"

module.exports = {
	connect: (callback)->
	    db = mongoose.connect(dbHost)
	    mongoose.connection.on('close', (str)->
	        console.err "DB disconnected: " + str
	    )
	    mongoose.connection.once('open', ->
	        console.log 'DB connected %s', dbHost
	        callback(mongoose)
	    )
	drop: (callback)->
		this.connect((mongoose)->
			mongoose.connection.db.dropDatabase(()->
				console.log 'DB', dbHost, 'droped'
				callback(mongoose)	
			)
		)
}