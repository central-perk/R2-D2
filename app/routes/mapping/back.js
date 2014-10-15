module.exports = function(app, mw, back) {

	// 此后不能写back下另外的get请求
    app.get('/back/*', back.index);
    
    // 重启服务
    app.post('/back/restart', back.restart);
    
    // 取消重启服务
    app.post('/back/restart/cancel', back.cancelRestart);
}
