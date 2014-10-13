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
                // console.log($state.params);
                // console.log(LoggerService);
                LogService.getList($state.params).then(function(logs) {
                    $scope.log = logs[0];
                });
                LoggerService.getList($state.params).then(function(loggers) {
                    $scope.loggers = loggers;
                });
            }
        }
    ]);
}
