module.exports = (app) ->
    app.get '/app', (req, res) ->
        if not req.user
            return res.redirect('/')
        res.render('dashboard', 'user': req.user)
