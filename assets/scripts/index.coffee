components = require './components'

validator = require 'vue-validator'


Vue.use(validator)

jQuery ($) ->
    # this is a bit horrible atm, but until vue-router is ready, is as good a solution as all the
    # available alternatives
    for own key of components
        component = components[key]
        if $(component.el).length
            new Vue(component)
