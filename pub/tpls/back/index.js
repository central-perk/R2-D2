module.exports = function(myApp) {
    myApp.controller('BackController', [
        '$scope',
        '$state',
        'growl',
        function($scope, $state, growl) {
            if ($state.is('back')) {
                $state.go('back.app');
            }
            $scope.copy = function(msg) {
            	msg = (msg || '') + '复制成功';
            	growl.addSuccessMessage(msg)
            }
        }
    ]);
}
