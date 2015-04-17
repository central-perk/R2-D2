var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

module.exports = {
    APP: {
        PORT: process.env.PORT || 8001,
        COOKIE: {
            maxAge: 60000 * 10
        },
        SESSION: {
            secret: 'logger',
            collection: 'sessions'
        },
        DB: {
            name: 'echuandan_logger',
        },
        PAGE: {
            perPage: 20
        },
        BASC_AUTH: {
            username: 'admin@echuandan.com',
            password: 'begeek@echuandan'
        }
    },
    FIELD_TYPE_MAP: {
        String: String,
        Number: Number,
        Boolean: Boolean,
        Date: Date,
        ObjectId: Schema.ObjectId
    },
    LOGGER: {
        level: {
            trace: 10,
            debug: 20,
            info: 30,
            warn: 40,
            error: 50,
            fatal: 60
        },
        defaultLevel: 30
    },
    LOGGERFILE: {
        status: {
            writeable: 10, //写入中
            unstorage: 20, //待入库
            storaging: 30, //入库中
            storaged: 40 //已入库
        },
        // maxSize: 5000
        maxSize: 100
    },
    STORAGE: {
        maxProcess: 1,
        maxLines: 50
    },
    TIME: {
        every10s: '*/10 * * * * *',
        every1m:  '* */1 * * * *',
        every5m:  '* */5 * * * *',
        every10m: '* */10 * * * *',
        every30m: '* */30 * * * *',
        every1h:  '* * */1 * * *',
        every2h:  '* * */2 * * *',
        every6h:  '* * */6 * * *',
        midnight: '0 10 1 * * *',
        sunday: '0 0 0 * * 0'
    },
};
