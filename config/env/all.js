module.exports = {
	PORT: process.env.PORT || 8001, //服务端口号
	LOG_INTERVAL: 5, //log文件创建的时间间隔
	PERPAGE: 5, //log文件前端显示每页条数
	STORAGE_CRON: '* */4 * * * *', // 入库的时间间隔，（当前为每4分钟一次）每个*依次代表秒、分、时、日、月、星期几，*/4表示间隔
	API: {
		nav: [{
			name: 'main',
			title: '说明',
			class: 'active'
		},{
			name: 'login',
			title: '登陆日志上报'
		}]
	}
};