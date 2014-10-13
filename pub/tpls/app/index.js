module.exports = function(myApp) {
    myApp.controller('AppController', [
        '$scope',
        '$state',
        function($scope, $state) {
            if ($state.is('back.app.edit')) {
                $state.go('back.app.edit');
            } else {
                $state.go('back.app.list');
            }
        }
    ]);

    myApp.controller('AppListController', [
        '$scope',
        '$state',
        '$timeout',
        'growl',
        'AppService',
        function($scope, $state, $timeout, growl, AppService) {
            $scope.init = function() {
                $scope.apps = AppService.list();
            }
        }
    ]);

    myApp.controller('AppEditController', [
        '$scope',
        '$state',
        '$timeout',
        'growl',
        'AppService',
        function($scope, $state, $timeout, growl, AppService) {
            $scope.init = function() {
                $scope.app = $scope.app || {};
            }
            $scope.create = function() {
                if (confirm('确认创建？')) {
                    AppService.create($scope.app);
                }
            }
        }
    ]);
}
