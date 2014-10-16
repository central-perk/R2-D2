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
                    _.forEach($scope.log.attrs, function(attr) {
                        attr.selected = true;
                    });
                    console.log($scope.log);
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
            $scope.selectedIcons = ["Gear","Heart","Camera"];
            $scope.icons = [{
                "value": "Gear",
                "label": "<i class=\"fa fa-gear\"></i> Gear"
            }, {
                "value": "Globe",
                "label": "<i class=\"fa fa-globe\"></i> Globe"
            }, {
                "value": "Heart",
                "label": "<i class=\"fa fa-heart\"></i> Heart"
            }, {
                "value": "Camera",
                "label": "<i class=\"fa fa-camera\"></i> Camera"
            }];
        }
    ]);
}
