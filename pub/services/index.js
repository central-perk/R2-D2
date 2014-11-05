module.exports = function(angular) {
    var myService = angular.module('myService', [
        'angular-lodash',
        'restangular'
    ]);
	require('services/app/index')(myService);
	require('services/back/index')(myService);
	require('services/log/index')(myService);
	require('services/logger/index')(myService);
}
