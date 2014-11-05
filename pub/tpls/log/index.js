module.exports = function(myApp) {
    myApp.controller('LogController', [
        '$scope',
        '$state',
        function($scope, $state) {
            if ($state.is('back.log.edit')) {
                $state.go('back.log.edit');
            } else {
                $state.go('back.log.list');
            }
        }
    ]);
    myApp.controller('LogListController', [
        '$scope',
        'cfpLoadingBar',
        'LogService',
        function($scope, cfpLoadingBar, LogService) {
            cfpLoadingBar.start();
            $scope.init = function() {
                LogService.getList().then(function(logs) {
                    cfpLoadingBar.complete();
                    $scope.logs = logs;
                    setUploadUrl();
                });
            }
            function setUploadUrl() {
                _.forEach($scope.logs, function(log) {
                    var appID = log.app._id,
                        logName = log.name,
                        token = log.app.token;
                    log.uploadUrl = '/upload/app/' + appID;
                    log.uploadUrl += '/logname/' + logName;
                    log.uploadUrl += '/token/' + token;
                });
            }
        }
    ]);

    myApp.controller('LogEditController', [
        '$scope',
        '$state',
        '$timeout',
        'AppService',
        'LogService',
        function($scope, $state, $timeout, AppService, LogService) {
            $scope.FIELD_TYPE_MAP = ['String', 'Number', 'Boolean', 'Date'];
            $scope.init = function() {
                if (_.isEmpty($state.params)) {
                    $scope.isEditForm = false;
                    $scope.submitBtnValue = '创建';
                    initAttrs();
                    // 获取应用列表
                    $scope.apps = AppService.list();
                } else {
                    $scope.isEditForm = true;
                    $scope.submitBtnValue = '保存';
                    // 获取日志信息
                    LogService.getList($state.params).then(function(logs) {
                        $scope.log = logs[0]
                    });
                }
            }
            $scope.submitCreate = function() {
                if (confirm('确认创建？')) {
                    LogService.create($scope.log).then(function() {
                        $timeout(function() {
                            $state.reinit();
                        }, 1000);
                    });
                }
            }
            $scope.submitUpdate = function() {
                if (confirm('确认保存？')) {
                    LogService.update($scope.log).then(function() {
                        $state.go('back.log.list');
                    });
                }
            }

            $scope.addAttr = function() {
                $scope.log.attrs.push({});
            }
            $scope.delAttr = function($index) {
                $scope.log.attrs.splice($index, 1);
            }
            $scope.submit = function() {
                if ($scope.isEditForm) {
                    $scope.submitUpdate();
                } else {
                    $scope.submitCreate();
                }
            }

            function initAttrs() {
                $scope.log = $scope.log || {};
                $scope.log.attrs = $scope.log.attrs || [];
                if (!$scope.log.attrs.length) {
                    $scope.addAttr();
                }
            }
        }
    ]);


}
