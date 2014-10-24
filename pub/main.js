require('libs/angular/angular.min');
require('libs/lodash/dist/lodash.min');
require('libs/jquery/dist/jquery.min');
ZeroClipboard = require('libs/zeroclipboard/dist/ZeroClipboard.min');
// moment = require('libs/moment/moment'); 

// angular modules
require('libs/angular-lodash/angular-lodash');
// require('libs/angular-bootstrap/ui-bootstrap.min');
require('libs/angular-bootstrap/ui-bootstrap-tpls');
require('libs/angular-ui-router/release/angular-ui-router.min');
require('libs/angular-loading-bar/build/loading-bar.min');
require('libs/angular-animate/angular-animate.min');
require('libs/angular-growl/build/angular-growl.min');
require('libs/restangular/dist/restangular.min');
require('libs/ng-clip/src/ngClip');
require('libs/angular-sanitize/angular-sanitize.min');

// require('libs/angular-moment/angular-moment');

require('libs/angular-cookies/angular-cookies.min'); // 暂时未用到
require('libs/angular-resource/angular-resource.min'); // 暂时未用到

// common
require('common/index')(angular);

// app services
require('services/index')(angular);

// app modules
require('modules/index')(angular);

var myApp = angular.module('myApp', [
    'angular-lodash',
    'ui.bootstrap',
    'ui.router',
    'chieffancypants.loadingBar',
    'ngAnimate',
    'angular-growl',
    'restangular',
    'ngClipboard',
    'ngSanitize',
    // 'angularMoment',
    'ngCookies',
    'ngResource',
    'myCommon',
    'myService',
    'myModule'
]);

require('config.app')(myApp);


require('tpls/index')(myApp);

require('routes')(myApp);
require('filters/index')(myApp);


myApp.controller('mainController', ['$scope', '$timeout',
    function($scope, $timeout) {
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
