api = require '../api'


module.exports =
    'el': '.menu--dropdown'

    'data':
        'active': false

    'methods':
        'toggle': (e) ->
            # toggle state
            if e.defaultPrevented
                return
            e.preventDefault()

            @active = not @active
