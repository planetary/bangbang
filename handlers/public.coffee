module.exports = (app) ->
    app.get '/styles', (req, res) ->
        res.render('styles')
