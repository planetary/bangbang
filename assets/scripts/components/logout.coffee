api = require '../api'


module.exports =
    'el': '.logout'

    'data':
        'progress': false

    'methods':
        'handle': (e) ->
            if e.defaultPrevented or @progress
                return
            e.preventDefault()

            @progress = true
            api.delete('/api/auth')
            .then (user) ->
                window.location.reload()
