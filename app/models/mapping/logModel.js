var mongoose = require('mongoose'),
    Schema = mongoose.Schema,
    _ = require('lodash'),
    config = process.g.config,
    utils = process.g.utils;

var schema = new Schema({
    appID: String,
    name: String,
    cname: String,
    attr: [{
       name: String,
       cname: String,
       dataType: String 
    }],
    ts: {
        type: Date,
        get: utils.formatTime,
        default: Date.now
    }
});

mongoose.model('logModel', schema);
