var path = require('path'),
    _ = require('lodash'),
    gulp = require('gulp'),
    gutil = require("gulp-util"),
    nodemon = require('gulp-nodemon'),
    rename = require("gulp-rename"),
    sourcemaps = require('gulp-sourcemaps'),
    scss = require('gulp-ruby-sass'),
    minifyCSS = require('gulp-minify-css'),
    uglify = require('gulp-uglify'),
    webpack = require("webpack"),
    webpackDevServer = require("webpack-dev-server");

var webpackConfig = require("./webpack.config.js");

var paths = {
    public: {
        css: ['pub/assets/*.css', '!pub/assets/*.min.css'],
        js: ['pub/assets/*.js', '!pub/assets/*.min.js']
    },
    scss: ['pub/scss/**/*.scss', 'pub/modules/**/*.scss', 'pub/tpls/**/*.scss'],
    js: [
        'pub/*.js',
        'pub/common/**/*.js',
        'pub/controllers/**/*.js',
        'pub/directives/**/*.js',
        'pub/filters/**/*.js',
        'pub/modules/**/*.js',
        'pub/services/**/*.js',
        'pub/tpls/**/*.js',
        'pub/vendor/**/*.js'
    ]
};


// webpack:build-dev
var myDevConfig = webpackConfig;
myDevConfig.devtool = "sourcemap";
myDevConfig.debug = true;
var devCompiler = webpack(myDevConfig);

gulp.task("webpack:build-dev", function(callback) {
    devCompiler.run(function(err, stats) {
        if (err) throw new gutil.PluginError("webpack:build-dev", err);
        gutil.log("[webpack:build-dev]", stats.toString({
            colors: true
        }));
        callback();
    });
});


// webpack:build-pro
var myProConfig = {
    output:  {
        path: path.join(__dirname, 'pub', 'assets', 'min')
    }
};
myProConfig = _.merge(webpackConfig, myProConfig);
myProConfig.plugins = myProConfig.plugins.concat(
    new webpack.DefinePlugin({
        "process.env": {
            "NODE_ENV": JSON.stringify("pro")
        }
    }),
    new webpack.optimize.DedupePlugin(),
    new webpack.optimize.UglifyJsPlugin()
);
var proCompiler = webpack(myProConfig);

gulp.task("webpack:build-pro", function(callback) {
    proCompiler.run(function(err, stats) {
        if (err) throw new gutil.PluginError("webpack:build-pro", err);
        gutil.log("[webpack:build-pro]", stats.toString({
            colors: true
        }));
        callback();
    });
});


gulp.task('scss', function() {
    gulp.src(paths.scss)
        .pipe(scss({
            loadPath: 'pub/scss',
            // sourcemap: true,
            // sourcemapPath: './scss',
            compass: true,
            require: ['bootstrap-sass', 'font-awesome-sass']
        }))
        .on('error', function(err) {
            console.log(err.message);
        })
        .pipe(gulp.dest('pub/assets'));
});

// 压缩样式
gulp.task('minify-css', function() {
    gulp.src(paths.public.css)
        .pipe(minifyCSS())
        .pipe(gulp.dest('pub/assets/min'));
});

// 压缩脚本
gulp.task('compress-js', function() {
    gulp.src(paths.public.js)
        .pipe(uglify({
            mangle: false
        }))
        .pipe(gulp.dest('pub/assets/min'));
});


gulp.task('server', function() {
    nodemon({
        script: 'server.js',
        ext: 'js',
        ignore: ['pub/**']
    }).on('restart', function() {
        console.log('restarted!');
    });
});


gulp.task("build-dev", ["webpack:build-dev"]);
gulp.task("build-pro", ["compress-js", 'minify-css']);

gulp.task('watch', function() {
    gulp.watch(paths.js, ["webpack:build-dev"]);
    gulp.watch(paths.scss, ['scss']);
});
gulp.task('default', ['scss', 'build-dev', 'watch', 'server']);
