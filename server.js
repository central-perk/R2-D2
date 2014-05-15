var http = require('http'),
	path = require('path'),
	express = require('express');

require(path.join(__dirname, 'libs', 'utils')).setG(__dirname);
var libs = process.g.libs;

require(libs.db).connect(function(mongoose) {
	var app = express();
	require(libs.express)(app, mongoose);
	require(libs.routes)(app);
	require(libs.cron);
	http.createServer(app).listen(app.get('port'), function() {
		console.log('Listen on port: ' + app.get('port'))
	});
});