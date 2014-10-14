module.exports = function(myService) {
    myService.factory('BackService', ['Restangular', 'growl', '$timeout', '$state',
        function(Restangular, growl, $timeout, $state) {
            var baseBacks = Restangular.all('back');
            return {
                getList: function(query) {
                    return baseBacks.getList(query);
                },
                restart: function() {
                    return baseBacks.customPOST({}, 'restart');
                },
                create: function(app) {
                    baseBacks.post(app).then(function(res) {
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
