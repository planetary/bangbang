module.exports = (app) ->
    app.get '/', (req, res) ->
        # Shows the homepage (and login screen) if not logged in; otherwise redirects to /app
        if req.user
            return res.redirect('/app')
        res.render('homepage')


    app.get '/styles', (req, res) ->
        # Renders the Airframe style guide
        res.render('styles')
