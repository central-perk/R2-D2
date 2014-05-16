# 将日志写入到文件

path = require('path')
fs = require('fs-extra')
utils = process.g.utils
logsPath = process.g.logsPath


module.exports = (logName)->
    fileName = logName + '.' + utils.getTime() + '.log'
    return (message, cb)->
        message = JSON.stringify(message, null, 0) + '\n'
        fs.writeFile(path.join(logsPath, fileName), message, {
            encoding: 'utf8'
            flag:'a'
        }, cb);
