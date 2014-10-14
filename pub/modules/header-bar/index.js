module.exports = function(myModule) {
    myModule.directive('headerBar', ['BackService', function(BackService) {
        return {
            restrict: 'E',
            templateUrl: '/modules/header-bar/index.html',
            controller: function($scope) {
                $scope.restart = function() {
                    if (confirm('确定要重启服务？')) {
                        BackService.restart();
                        alert('服务将在10秒后重启')
                    }
                }
            }
        };
    }]);
}
