module.exports = function(myApp) {
    myApp.config(['$stateProvider', '$urlRouterProvider', '$locationProvider',
        function($stateProvider, $urlRouterProvider, $locationProvider) {
            // 开启html5mode
            $locationProvider.html5Mode(true)
            // $locationProvider.html5Mode(true).hashPrefix('!');

            // 不符合条件的路由指向首页
            $urlRouterProvider.otherwise('/back');

            // 路由
            $stateProvider
                .state('back', {
                    url: '/back',
                    templateUrl: '/tpls/back/index.html',
                    controller: 'BackController'
                })
                .state('back.app', {
                    url: '/app',
                    template: '<ui-view/>',
                    controller: 'AppController'
                })
                .state('back.app.list', {
                    url: '/list',
                    templateUrl: '/tpls/app/list.html',
                    controller: 'AppListController'
                })
                .state('back.app.edit', {
                    url: '/edit',
                    templateUrl: '/tpls/app/edit.html',
                    controller: 'AppEditController'
                })
                .state('back.log', {
                    url: '/log',
                    template: '<ui-view/>',
                    controller: 'LogController'
                })
                .state('back.log.list', {
                    url: '/list',
                    templateUrl: '/tpls/log/list.html',
                    controller: 'LogListController'
                })
                .state('back.log.edit', {
                    url: '/edit?app&name',
                    templateUrl: '/tpls/log/edit.html',
                    controller: 'LogEditController'
                })
                .state('back.logger', {
                    url: '/logger',
                    template: '<ui-view/>',
                    controller: 'LoggerController'
                })
                .state('back.logger.list', {
                    url: '/list?app&name&page',
                    templateUrl: '/tpls/logger/list.html',
                    controller: 'LoggerListController'
                })
        }
    ]);
    // 异步路由
    // app.run(['$rootScope', '$urlRouter',
    //     function($rootScope, $urlRouter) {
    //         $rootScope.$on('$locationChangeSuccess', function(evt) {
    //             // Halt state change from even starting
    //             evt.preventDefault();
    //             // Perform custom logic
    //             var meetsRequirement = /* ... */
    //                 // Continue with the update and state transition if logic allows
    //                 if (meetsRequirement) $urlRouter.sync();
    //         });
    //     }
    // ]);
}
