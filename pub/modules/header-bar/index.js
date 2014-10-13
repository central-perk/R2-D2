module.exports = function(myModule) {
    myModule.directive('headerBar', ['BackService',function() {
            return {
                restrict: 'E',
                templateUrl: '/modules/header-bar/index.html',
                controller: function($scope) {
                    
                }
            };
        }]);
}
