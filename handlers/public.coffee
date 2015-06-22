module.exports = (app) ->
    app.get '/', (req, res) ->
        res.render('homepage')


    app.get '/styles', (req, res) ->
        res.render('styles')
