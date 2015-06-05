module.exports = function(angular) {
	var myModule = angular.module('myModule', [
		'angular-lodash'
	]);
	require('modules/header-bar/index')(myModule);
	require('modules/paging/index')(myModule);
	require('modules/side-nav/index')(myModule);
}
