var dbBackup = require('./index');

//本地测试
dbBackup.init({
    path: '/Users/terry/Documents/code/db_back_test',
    host: '127.0.0.1:27017',
    name: 'echuandan_development'
});
