path = require('path')
_ = require('lodash')
process.env.NODE_ENV = process.env.NODE_ENV || 'dev'

module.exports = _.merge(
    require(path.join(__dirname, 'env', 'all')),
    require(path.join(__dirname, 'env', process.env.NODE_ENV)) || {}
);