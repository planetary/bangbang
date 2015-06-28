Vue.component 'menu',
    'template': require('templates/menu/menu')()


    'props': [{
        'name': 'title'
        'type': String
    }]


    'data': ->
        'align': 'left'
        'title': ''
