coffeeCoverage = require 'coffee-coverage'
istanbulVar = coffeeCoverage.findIstanbulVariable()


coffeeCoverage.register(
    'instrumentor': 'istanbul'
    'basePath': __dirname
    'exclude': [
        'config'
        'gulp'
        'node_modules'
        'tests'
        'register-coverage.coffee'
    ]
    'coverageVar': istanbulVar
    'initAll': true
    # Only write a coverage report if we're not running inside of Istanbul.
    'writeOnExit': if not istanbulVar? then (__dirname + '/coverage/coverage-coffee.json')
)
