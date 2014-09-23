module.exports = {
	PORT: process.env.PORT || 8001, //服务端口号
	// LOG_MAX_SIZE: 50000, // 50k
	// LOG_MAX_SIZE: 1000000, // 1M
	LOG_MAX_SIZE: 100, // 1M
	PERPAGE: 20, //log文件前端显示每页条数
	STORAGE: {
 		cron: '38 * * * * *', // 定时入库的时间
		// cron: '40 39 14 * * *', // 定时入库的时间
		// delay: 5000, // 日志文件写满后入库的延时ms， 半分钟后入库
		maxProcess: 1, //队列同时处理的文件数量
		maxLines: 50 //一次入库操作的数据行数
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
			title: '创建应用',
			href: 'auth',
			class: 'active'
		}, {
			title: '创建日志',
			href: 'logmodel'
		}]
	},
};