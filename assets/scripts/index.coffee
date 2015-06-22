views = require './views'

validator = require 'vue-validator'


Vue.use(validator)

jQuery ($) ->
    # this is a bit horrible atm, but until vue-router is ready, is as good a solution as all the
    # available alternatives
    for own key of views
        view = views[key]
        if $(view.el).length
            new Vue(view)
