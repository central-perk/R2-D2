path = require('path')
fs = require('fs-extra')
utils = process.g.utils
logsPath = process.g.logsPath


module.exports = (logName)->
    fileName = logName + '.' + utils.getTime() + '.log'
    return (message)->
        message = JSON.stringify(message, null, 0) + '\n'
        fs.writeFileSync(path.join(logsPath, fileName), message, {
            encoding: 'utf8'
            flag:'a'
        });
