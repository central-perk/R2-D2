module.exports = function(myCommon) {
    myCommon.filter('dateFormat', function($filter) {
            return function(data) {
                if (data) {
                    return $filter('date')(new Date(data), 'yyyy-MM-dd');
                } else {
                    return '/'
                }
            };
        })
        .filter('timeFormat', function($filter) {
            return function(data) {
                if (data) {
                    return $filter('date')(new Date(data), 'HH:mm:ss');
                } else {
                    return '/'
                }
            };
        })
        .filter('dateTimeFormat', function($filter) {
            return function(data) {
                if (data) {
                    return $filter('date')(new Date(data), 'yyyy-MM-dd HH:mm');
                } else {
                    return '/'
                }
            };
        })
        .filter('monthTimeFormat', function($filter) {
            return function(data) {
                if (data) {
                    return $filter('date')(new Date(data), 'MM-dd HH:mm');
                } else {
                    return '/'
                }
            };
        });
}
