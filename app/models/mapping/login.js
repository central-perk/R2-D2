var mongoose = require('mongoose'),
    Schema = mongoose.Schema,
    _ = require('lodash'),
    config = process.g.config,
    utils = process.g.utils;

var schema = new Schema({
    timestamp: Date,
    openID: String
});

mongoose.model('login', schema);