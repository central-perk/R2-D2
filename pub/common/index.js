module.exports = function(angular) {
	var myCommon = angular.module('myCommon', [
        'angular-lodash'
    ]);

	require('common/directives/index')(myCommon);
	require('common/filters/index')(myCommon);
	require('common/services/index')(myCommon);
}
