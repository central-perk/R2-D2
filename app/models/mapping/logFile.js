var mongoose = require('mongoose'),
    Schema = mongoose.Schema,
    _ = require('lodash'),
    config = process.g.config,
    logFileStatus = config.STATUS.LOGFILE
    utils = process.g.utils;

var schema = new Schema({
    appID: String,
    name: String,
    fileName: String,
    status: {
        type: Number,
        default: logFileStatus.writeable
    },
    ts: {
        type: Date,
        get: utils.formatTime,
        default: Date.now
    }
});

mongoose.model('logFile', schema);
