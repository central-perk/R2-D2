module.exports = {
	PORT: process.env.PORT || 8001, //服务端口号
	LOG_MAX_SIZE: 150, // 5M
	// LOG_MAX_SIZE: 5000000, // 5M
	PERPAGE: 5, //log文件前端显示每页条数
	STORAGE: {
		cron: '* * 2 * * *', // 定时入库的时间
		delay: '30000' // 日志文件写满后入库的延时ms， 半分钟后入库
	},
	API: {
		nav: [{
			name: 'main',
			title: '说明',
			class: 'active'
		}, {
			name: 'login',
			title: '登陆日志上报'
		}]
	},
	STATUS: {
		LOGFILE: {
			writeable: 10,
			unstorage: 20,
			storaging: 30,
			storaged: 40
		}
	}

};