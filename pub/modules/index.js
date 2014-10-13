module.exports = function(angular) {
    var myModule = angular.module('myModule', [
        'angular-lodash'
    ]);
	require('modules/side-nav/index')(myModule);
}
