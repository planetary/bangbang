module.exports =
    'name': 'session'  # name of the session cookie
    'secret': '003d75699fc0412782b4cb59b489a3f4'  # secret key used to sign cookie session data
    'maxAge': 30 * 24 * 3600 * 1000  # session cookie lifetime
    'signed': true  # this option is stupid and should not exist; major h4xx if set to false!!!!!!!
    'overwrite': true  # makes life easier
