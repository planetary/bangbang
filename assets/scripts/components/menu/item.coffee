Vue.component 'menu-item',
    'template': require('templates/menu/item')()


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
