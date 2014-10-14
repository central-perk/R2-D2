require('libs/angular/angular.min');
require('libs/lodash/dist/lodash.min');
require('libs/jquery/dist/jquery.min');
ZeroClipboard = require('libs/zeroclipboard/dist/ZeroClipboard.min');
// moment = require('libs/moment/moment');

// angular modules
require('libs/angular-lodash/angular-lodash');
require('libs/angular-strap/dist/angular-strap.min');
require('libs/angular-strap/dist/angular-strap.tpl.min');
require('libs/angular-ui-router/release/angular-ui-router.min');
require('libs/angular-loading-bar/build/loading-bar.min');
require('libs/angular-animate/angular-animate.min');
require('libs/angular-growl/build/angular-growl.min');
require('libs/restangular/dist/restangular.min');
require('libs/ng-clip/src/ngClip');

// require('libs/angular-moment/angular-moment');

require('libs/angular-cookies/angular-cookies.min'); // 暂时未用到
require('libs/angular-resource/angular-resource.min'); // 暂时未用到



var myApp = angular.module('myApp', [
    'angular-lodash',
    'mgcrea.ngStrap',
    'ui.router',
    'chieffancypants.loadingBar',
    'ngAnimate',
    'angular-growl',
    'restangular',
    'myService',
    'myModule',
    'ngClipboard',
    // 'angularMoment',

    'ngCookies',
    'ngResource'
]);

require('config.app')(myApp);

// require services
require('services/index')(angular);

// require modules
require('modules/index')(angular);



require('tpls/index')(myApp);

require('routes')(myApp);
require('js/filters/index')(myApp);
require('js/directives/index')(myApp);


myApp.controller('mainController', ['$scope', '$timeout', 'cfpLoadingBar',
    function($scope, $timeout, cfpLoadingBar) {
        // cfpLoadingBar.start();

        // $timeout(function() {
        //     cfpLoadingBar.complete();
        // }, 3000);
    }
]);



angular.bootstrap(document, ['myApp']);


// require('libs/zeroclipboard/dist/ZeroClipboard.min');
// // zeroClipboard swf 文件路径配置
// myApp.config(['ngClipProvider', function(ngClipProvider) {
//     ngClipProvider.setPath("/libs/zeroclipboard/dist/ZeroClipboard.swf");
// }]);
