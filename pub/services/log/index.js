module.exports = function(myService) {
    myService.factory('LogService', ['Restangular', 'growl', '$timeout', '$state',
        function(Restangular, growl, $timeout, $state) {
            var baseLogs = Restangular.all('log');
            return {
                get: function(query) {
                    return baseLogs.get(query).$object;
                },
                getList: function(query) {
                    temp = _.cloneDeep(query)
                    delete temp.page
                    return baseLogs.getList(temp);
                },
                list: function(query) {
                    return baseLogs.getList(query).$object;
                },
                create: function(Log) {
                    return baseLogs.post(Log).then(function(res) {
                        growl.addSuccessMessage(res.msg);
                    });
                },
                update: function(Log) {
                    return Log.put().then(function(res) {
                        growl.addSuccessMessage(res.msg);
                    });
                },
                groupApp: function() {
                    return baseLogs.get('group/app');
                    // return Restangular.all('log').one('group','app').get().$object;
                }
            }
        }
    ])
}
