module.exports = function(app, mw, back) {
    app.get('/back', back.index);
    
    // 重启服务
    app.post('/back/restart', back.restart);
    
    // 取消重启服务
    app.post('/back/restart/cancel', back.cancelRestart);
}
