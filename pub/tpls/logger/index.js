module.exports = function(myApp) {
    myApp.controller('LoggerController', [
        '$scope',
        '$state',
        function($scope, $state) {
            if ($state.is('back.logger')) {
                $state.go('back.logger.list');
            }
        }
    ]);
    myApp.controller('LoggerListController', [
        '$scope',
        '$state',
        'LogService',
        'LoggerService',
        function($scope, $state, LogService, LoggerService) {
            $scope.init = function() {
                LogService.getList($state.params).then(function(logs) {
                    $scope.log = logs[0];
                });
                LoggerService.list($state.params).then(function(data) {
                    $scope.loggers = data.loggers;
                    $scope.paging = $scope.paging || data.paging;
                    $scope.paging.page = 0;
                });
            }
            $scope.doPage = function(none, page) {
                $state.params.page = page;
                LoggerService.list($state.params).then(function(data) {
                    $scope.loggers = data.loggers;
                });
            }
        }
    ]);
}
