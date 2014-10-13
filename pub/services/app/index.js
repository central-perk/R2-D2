module.exports = function(myService) {
    myService.factory('AppService', ['Restangular', 'growl', '$timeout', '$state',
        function(Restangular, growl, $timeout, $state) {
            var baseApps = Restangular.all('app');
            return {
                list: function() {
                    return baseApps.getList().$object;
                },
                create: function(app) {
                    baseApps.post(app).then(function(res) {
                        growl.addSuccessMessage(res.msg);
                        $timeout(function() {
                            $state.reinit();
                        }, 1000);
                    }, function(res) {
                        growl.addErrorMessage(res.data.msg, {
                            ttl: -1
                        });
                    });
                }
            }
        }
    ])
}
