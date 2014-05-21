var mongoose = require('mongoose'),
    Schema = mongoose.Schema,
    _ = require('lodash'),
    config = process.g.config,
    utils = process.g.utils;

var schema = new Schema({
    appName: String,
    appID: Number,
    token: String,
    status: Number,
    ts: {
        type: Date,
        get: utils.formatTime,
        default: Date.now
    }
});

mongoose.model('auth', schema);