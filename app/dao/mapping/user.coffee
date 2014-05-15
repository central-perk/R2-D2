userModel = require('mongoose').model('user')

module.exports = {
	getUserByID: (userID, callback)->
		userModel.findOne({_id: userID}, 'username email', callback)
	getUserByEmail: (email, callback)->
		userModel.findOne({email}, 'username email', callback)
}

