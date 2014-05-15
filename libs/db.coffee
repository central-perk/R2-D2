path = require('path')
exec = require('child_process').exec
async = require('async')
fs = require('fs-extra')
mongoose = require('mongoose')

config = process.g.config
utils = process.g.utils
dbHost = "mongodb://#{config.DB.host}:#{config.DB.port}/#{config.DB.name}"

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