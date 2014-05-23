var mongoose = require('mongoose'),
    Schema = mongoose.Schema,
    _ = require('lodash'),
    config = process.g.config,
    utils = process.g.utils;

var schema = new Schema({
    appID: String,
    type: String,
    attributes: [{
        key: String,
        value: String
    }],
    ts: {
        type: Date,
        get: utils.formatTime,
        default: Date.now
    }
});

mongoose.model('logModel', schema);
