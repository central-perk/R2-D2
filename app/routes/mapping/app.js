module.exports = function(app, mw, App) {
	app.post('/app', App.create);
	app.get('/app', App.list);
}