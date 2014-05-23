module.exports = {
	PORT: process.env.PORT || 8001, //服务端口号
	LOG_MAX_SIZE: 400, // 5M
	// LOG_MAX_SIZE: 5000000, // 5M
	PERPAGE: 5, //log文件前端显示每页条数
	STORAGE: {
		// cron: '* * 2 * * *', // 定时入库的时间
		cron: '* * */3 * * *', // 定时入库的时间

		delay: 3000, // 日志文件写满后入库的延时ms， 半分钟后入库
		maxProcess: 1, //队列同时处理的文件数量
		maxLines: 20 //一次入库操作的数据行数
	},
	STATUS: {
		LOGFILE: {
			writeable: 10, //可写入
			unstorage: 20, //待入库
			storaging: 30, //入库中
			storaged: 40 //已入库
		},
		AUTH: {
			enable: 10,
			disable: 20
		}
	},
	BACK: {
		nav: [{
			name: 'auth',
			title: '授权',
			class: 'active'
		}, {
			name: 'logmodel',
			title: '日志模型'
		}]
	},
};