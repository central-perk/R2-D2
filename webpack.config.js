var path = require('path');
var webpack = require('webpack');
var WebpackDevServer = require("webpack-dev-server");

var pubPath = path.join(__dirname, 'pub'),
    nodeModulesPath = path.join(__dirname, 'node_modules'),
    assetsPath = path.join(pubPath, 'assets'),
    jsPath = path.join(pubPath, 'js'),
    scssPath = path.join(pubPath, 'scss'),
    modulesPath = path.join(pubPath, 'modules'),
    libsPath = path.join(pubPath, 'libs');

module.exports = {
    context: pubPath, // entry的basePath
    entry: {
        main: './main'
    },
    output: {
        path: assetsPath,
        filename: 'main.js',
        publicPath: '/assets' // 静态文件的basePath
    },
    resolve: {
        root: [pubPath, scssPath, modulesPath],
        alias: {
            'pub$':         '/pub/',
            'assets$':      '/pub/assets',
            'common$':      '/pub/common',
            'controllers$': '/pub/controllers',
            'directives$':  '/pub/directives',
            'filters$':     '/pub/filters',
            'libs$':        '/pub/libs',
            'modules$':     '/pub/modules',
            'scss$':        '/pub/scss',
            'services$':    '/pub/services',
            'tpls$':        '/pub/tpls',
            'views$':       '/pub/vieww',
            'js$':          '/pub/js'
        },
        extensions: ['', '.js', '.coffee', '.html', '.css', '.scss']
    },
    plugins: [],
    module: {
        loaders: [{
            test: /\.coffee$/,
            loader: 'coffee'
        }, {
            test: /\.html$/,
            loader: 'html'
        }, {
            test: /\.json$/,
            loader: 'json'
        }, {
            test: /\.css$/,
            loader: 'style!css'
        }, {
            test: /\.scss$/,
            loader: 'style!css!autoprefixer!sass'
        }, {
            test: /\.woff$/,
            loader: "url?limit=10000&minetype=application/font-woff"
        }, {
            test: /\.ttf$/,
            loader: "file"
        }, {
            test: /\.eot$/,
            loader: "file"
        }, {
            test: /\.svg$/,
            loader: "file"
        }]
    }
};
