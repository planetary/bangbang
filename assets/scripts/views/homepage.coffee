api = require '../api'


module.exports =
    'el': '.login--homepage'

    'data':
        # data set
        'email': ''
        'name': ''
        'password': ''
        'password2': ''
        # extra validation
        'emailAvailable': false
        'passwordMismatch': false
        'passwordIncorrect': false
        'emailError': false
        'passwordError': false
        'password2Error': false
        'nameError': false

    'methods':
        'focusInput': (name) ->
            # if the component is focused, only show validation errors if they were present before
            # the component was focused
            @["#{name}Error"] = @validation[name].dirty and @validation[name].invalid
        'blurInput': (name) ->
            # if the component is blured, always show any validation error have been encountered
            @["#{name}Error"] = true
        'submitForm': (e) ->
            e.preventDefault()

            if @emailAvailable
                # create new user with unused email
                api.post '/api/users',
                    'email': @email
                    'name': @name
                    'password': @password
                .then (user) ->
                    console.log('created ' + user)
            else
                # attempt to login as @email
                api.post '/api/auth',
                    'email': @email
                    'password': @password
                .then (user) ->
                    console.log('logged in as ' + user)
                .catch api.ForbiddenError, =>
                    @passwordIncorrect = true

    'watch':
        'email': (newValue, oldValue) ->
            Vue.nextTick =>
                # the watcher is called before the validator; wait a tick before testing validation
                # status
                if @validation.email.valid
                    api.post '/api/users/exists',
                        'email': @email
                    .then (exists) =>
                        @emailAvailable = not exists
        'password2': ->
            @passwordMismatch = @password isnt @password2

