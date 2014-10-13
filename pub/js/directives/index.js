module.exports = function(myApp) {
    myApp.directive('dateFieldFomat', ['$filter', function($filter) {
        return {
            restrict: 'A',
            scope: {
                fieldType: '@',
                ngBind: '='
            },
            link: function($scope, $ele, $attrs) {
                if ($scope.fieldType === 'Date') {
                    $scope.ngBind = $filter('date')(new Date($scope.ngBind), 'yyyy-MM-dd HH:mm');
                }
            }
        }
    }]);
}
