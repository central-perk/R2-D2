path 	= require('path')
fs 		= require('fs-extra')
CronJob = require('cron').CronJob
async 	= require('async')
moment 	= require('moment')
config 	= process.g.config
utils 	= process.g.utils

DB = config.APP.DB
CONFIG_TIME = process.g.config.TIME


BackupDB = require(path.join(process.g.rootPath, 'tools', 'db-backup', 'index.js'));
loggerFileCtrl = utils.getCtrl('loggerFile')


# 开启服务后 5s 执行
d = moment().add(5, 'seconds')
hour = d.hours()
minute = d.minutes()
second = d.seconds()
after5s = "#{second} #{minute} #{hour} * * *"


# 数据库备份
jobBackupDB = new CronJob(CONFIG_TIME.midnight, ()->

	# 数据库备份文件夹路径
	dbBackupPath = path.join(process.g.rootPath, '..', 'logger_backup', 'db')

	# 确保数据库备份文件夹存在
	fs.ensureDirSync(dbBackupPath)
	console.log dbBackupPath
	console.log (DB.host + ':' + DB.port)
	console.log DB.name
	BackupDB.init({

		# 备份数据存储父级目录
		path: dbBackupPath

		# 数据库连接
		host: DB.host + ':' + DB.port

		# 数据库名称
		name: DB.name + '_' + process.env.NODE_ENV
	});
null, true, 'Asia/Shanghai')

# 日志文件定时清空
jobCleanLogFile = new CronJob(config.TIME.sunday, ()->
	loggerFileCtrl.clean();
, null, true, 'Asia/Shanghai');
