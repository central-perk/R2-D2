module.exports = function(myApp) {
	require('tpls/app/index')(myApp);
	require('tpls/back/index')(myApp);
	require('tpls/log/index')(myApp);
	require('tpls/logger/index')(myApp);
}
