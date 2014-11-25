/**
 * @ngDoc directive
 * @name ng.directive:paging
 *
 * @description
 * A directive to aid in paging large datasets
 * while requiring a small amount of page
 * information.
 *
 * @element EA
 *
 */

module.exports = function(myModule) {
    myModule.directive('paging', function() {

        return {
            restrict: 'EA',
            scope: {
                paging: '=',
                onPaging: '&'
            },
            template:
                '<ul class="pagination">' +
                    '<li ng-class="{disabled: noPrevious()}">' +
                        '<a href="" ng-click="pagePrevious()">上一页</a>' +
                    '</li>' +
                    '<li ng-class="{disabled: noNext()}">' +
                        '<a href="" ng-click="pageNext()">下一页</a>' +
                    '</li>' +
                '</ul>',
            link: function ($scope, $ele, $attrs) {
                // 初始化paging对象
                $scope.paging = $scope.paging || {};
                $scope.paging.curPage = $scope.paging.curPage || 1;

                $scope.noPrevious = function() {
                    return $scope.paging.curPage <= 1;
                }
                $scope.noNext = function() {
                    return $scope.paging.noNext;
                }
                $scope.pagePrevious = function() {
                    if (!$scope.noPrevious()) {
                        $scope.onPaging({pageNum: $scope.paging.curPage - 1});
                    }
                }
                $scope.pageNext = function() {
                    if (!$scope.noNext()) {
                        $scope.onPaging({pageNum: $scope.paging.curPage + 1});
                    }
                }
            }
        }
    });
}