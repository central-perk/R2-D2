module.exports = function(myService) {
    myService.factory('LoggerService', ['Restangular', 'growl', '$timeout', '$state',
        function(Restangular, growl, $timeout, $state) {
            var baseLoggers = Restangular.all('logger');
            return {
                getList: function(query) {
                    return baseLoggers.getList(query);
                },
                list: function(query) {
                    return baseLoggers.customGET('', query);
                },
                customPOST: function(body, path, query) {
                    return baseLoggers.customPOST(body, path, query);
                }
            }
        }
    ])
}