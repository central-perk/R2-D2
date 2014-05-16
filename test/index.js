process.env.NODE_ENV = 'test';



var path = require('path'),
    request = require('request'),
    request = request.defaults({
        json: true
    }),
    fs = require('fs-extra'),
    _ = require('lodash'),
    should = require('should');
require(path.join(__dirname, '..', 'libs', 'utils')).setG(path.join(__dirname, '..'));


var libs = process.g.libs,
    utils = process.g.utils,
    config = process.g.config,
    logsPath = process.g.logsPath,
    storage = require(path.join(process.g.controllersPath, 'mapping', 'storage')),
    host = 'http://localhost:' + config.PORT,
    GET = VERB('get'),
    POST = VERB('post'),
    DELETE = VERB('delete'),
    PUT = VERB('put');


function VERB(method) {
    return function(options, callback) {
        request[method](options, function(err, response, body) {
            if (err) throw err;
            if (!err && response.statusCode == 200) {
                callback(body);
            }
        });
    }
}

// 测试前需要先将测试数据库，所有的log文件先清空
describe('clear', function() {
    describe('#db', function() {
        it('should success', function(done) {
            require(libs.db).drop(function(mongoose) {
                done();
            })
        });
    });
    describe('#logs', function() {
        it('should success', function(done) {
            fs.removeSync(logsPath);
            fs.mkdirsSync(logsPath);
            done();
        });
    });
});

describe('login', function() {
    // 接口正常
    describe('#port', function() {
        it('should success', function(done) {
            var timestamp = (new Date()).getTime(),
                url = host + '?_type=openLogin&timestamp=' + timestamp + '&openID=12345';
            GET(url, function(body) {
                body.status.should.eql(1);
                done();
            });
        });
    });
    // 日志文件被记录
    describe('#file', function() {
        it('should exist', function(done) {
            var logFileName = 'login.' + process.g.utils.getTime() + '.log',
                logFilePath = path.join(logsPath, logFileName);

            fs.exists(logFilePath, function(exists) {
                exists.should.eql(true);
                done();
            });
        });
    });
    // 日志被记录到数据库, 日志文件被销毁
    describe('#storage', function() {
        it('should recorded', function(done) {
            POST(host + '/storage', function(body) {
                var logFileName = 'login.' + process.g.utils.getTime() + '.log',
                    logFilePath = path.join(logsPath, logFileName);
                fs.exists(logFilePath, function(exists) {
                    exists.should.eql(false);
                    done();
                });
            })
        });
    });
    // 日志查询, 只有一条数据
    describe('#list', function() {
        it('should exist', function(done) {
            GET(host + '/login', function(body) {
                body.message.logins.length.should.eql(1)
                done();
            })
        });
    });
});