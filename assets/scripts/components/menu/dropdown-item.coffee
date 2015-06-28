Vue.component 'menu-dropdown-item',
    'template': require('templates/menu/dropdown-item')()


    'props': [{
        'name': 'active'
        'type': Boolean
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
