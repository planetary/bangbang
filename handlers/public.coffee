module.exports = (app) ->
    app.get '/', (req, res) ->
        # Shows the homepage (and login screen) if not logged in; otherwise redirects to /app
        if req.user
            return res.redirect('/app')
        res.render('homepage')


    app.get '/features', (req, res) ->
        # Renders the Features page
        if req.user
            return res.redirect('/app')
        res.render('features', 'page': 'features')


    app.get '/pricing', (req, res) ->
        # Renders the Pricing page
        if req.user
            return res.redirect('/app')
        res.render('pricing', 'page': 'pricing')


    app.get '/docs', (req, res) ->
        # Renders the documentation page
        if req.user
            return res.redirect('/app')
        res.render('docs', 'page': 'docs')


    app.get '/styles', (req, res) ->
        # Renders the Airframe style guide
        res.render('styles')
