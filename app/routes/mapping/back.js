module.exports = function(app, mw, back) {
    app.get('/back', back.index);
}
