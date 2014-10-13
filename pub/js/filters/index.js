module.exports = function(myApp) {
    myApp.filter('dateFormat', function($filter) {
        return function(data) {
        	if (!data) {
        		return '/'
        	} else {
        		return $filter('date')(new Date(data), 'yyyy-MM-dd');
        	}
        };
    });
    myApp.filter('timeFormat', function($filter) {
        return function(data) {
        	if (!data) {
        		return '/'
        	} else {
        		return $filter('date')(new Date(data), 'HH:mm:ss');
        	}
        };
    });
    myApp.filter('dateTimeFormat', function($filter) {
        return function(data) {
        	if (!data) {
        		return '/'
        	} else {
        		return $filter('date')(new Date(data), 'yyyy-MM-dd HH:mm');
        	}
        };
    });
    myApp.filter('logLevelFilter', function($filter) {
        return function(data) {
            var tmp = '';
            switch(data) {
                case 10:
                    tmp = '追踪'
                    break;
                case 20:
                    tmp = '调试'
                    break;
                case 30:
                    tmp = '信息'
                    break;
                case 40:
                    tmp = '警告'
                    break;
                case 50:
                    tmp = '错误'
                    break;
                case 60:
                    tmp = '致命'
                    break;
            }
            return tmp;
        };
    });
    myApp.filter('logLevelClass', function($filter) {
        return function(data) {
            var tmp = '';
            switch(data) {
                case 10:
                    tmp = 'success'
                    break;
                case 20:
                    tmp = 'active'
                    break;
                case 30:
                    tmp = 'info'
                    break;
                case 40:
                    tmp = 'warning'
                    break;
                case 50:
                    tmp = 'danger'
                    break;
                case 60:
                    tmp = 'danger'
                    break;
            }
            return tmp;
        };
    });
}
