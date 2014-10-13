module.exports = function(myModule) {
    myModule.directive('sideNav', ['LogService', function(LogService) {
        return {
            restrict: 'E',
            templateUrl: '/modules/side-nav/index.html',
            controller: function($scope) {
                LogService.groupApp().then(function(navs) {
                    $scope.navs = navs;
                });
            }
        };
    }]);
}
