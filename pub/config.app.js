module.exports = function(myApp) {
	// config angular-loading-bar
	myApp.config(['cfpLoadingBarProvider',
	    function(cfpLoadingBarProvider) {
	        cfpLoadingBarProvider.includeSpinner = false;
	    }
	]);

	// config angular-growl
	myApp.config(['growlProvider', function(growlProvider) {
	    growlProvider.globalTimeToLive(1000);
	}]);

	// 修复$state.reload不init控制器
	myApp.config(['$provide', function($provide) {
	    $provide.decorator('$state', function($delegate) {
	        $delegate.reinit = function() {
	            this.transitionTo(this.current, this.$current.params, {
	                reload: true,
	                inherit: true,
	                notify: true
	            });
	        };
	        return $delegate;
	    });
	}]);

	// config restangular
	myApp.config(['RestangularProvider', function(RestangularProvider) {
	    RestangularProvider.setRestangularFields({
	        id: "_id",
	        route: "restangularRoute",
	        selfLink: "self.href"
	    });
	    RestangularProvider.setRequestInterceptor(function(element, operation, route, url) {
	        if (operation === 'put') {
	            delete element._id;
	        }
	        return element;
	    });
	}]).run(['Restangular', 'growl', function(Restangular, growl) {
	    Restangular.setErrorInterceptor(function(response, deferred, responseHandler) {
	        if (response.status === 500) {
	            growl.addErrorMessage(response.data.msg, {
	                ttl: -1
	            });
	            return false;
	        }
	        return true;
	    });
	}]);

	// config ng-clip
	myApp.config(['ngClipProvider', function(ngClipProvider) {
	    ngClipProvider.setPath("/libs/zeroclipboard/dist/ZeroClipboard.swf");
	}]);
};