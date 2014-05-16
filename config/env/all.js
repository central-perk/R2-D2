module.exports = {
	PORT: process.env.PORT || 8001, //服务端口号
	LOG_INTERVAL: 5, //log文件创建的时间间隔
	PERPAGE: 5, //log文件前端显示每页条数
	API: {
		nav: [{
			name: 'main',
			title: '说明',
			class: 'active'
		},{
			name: 'login',
			title: '登陆'
		}]
	}
};