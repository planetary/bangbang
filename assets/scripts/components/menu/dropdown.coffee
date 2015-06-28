Vue.component 'menu-dropdown',
    'template': require('templates/menu/dropdown')()


    'props': [{
        'name': 'active'
        'type': Boolean
    }, {
        'name': 'align'
        'type': String
    }, {
        'name': 'caption'
        'type': String
    }, {
        'name': 'title'
        'type': String
    }, {
        'name': 'href'
        'type': String
    }]


    'data': ->
        'active': false
        'align': 'left'
        'caption': ''
        'title': ''
        'href': ''


    'methods':
        'toggle': (e) ->
            # toggle state
            if e.defaultPrevented
                return
            e.preventDefault()

            @active = not @active
