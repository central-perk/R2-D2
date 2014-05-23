var mongoose = require('mongoose'),
    Schema = mongoose.Schema,
    _ = require('lodash'),
    config = process.g.config,
    AUTH_STATUS = config.STATUS.AUTH
    utils = process.g.utils;

var schema = new Schema({
    appName: String,
    appID: String,
    token: String,
    status: {
        type: Number,
        default: AUTH_STATUS.enable
    },
    ts: {
        type: Date,
        get: utils.formatTime,
        default: Date.now
    }
});

mongoose.model('auth', schema);