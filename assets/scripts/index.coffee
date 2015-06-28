bulk = require 'bulk-require'
validator = require 'vue-validator'

# register components and vendor scripts
bulk(__dirname, 'components/**/*.coffee')
bulk(__dirname, 'vendor/**/*.coffee')

Vue.use(validator)

jQuery ($) ->
    new Vue('el': 'body')
