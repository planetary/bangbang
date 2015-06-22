config = require './config'

csrf = require 'csurf'
express = require 'express'
morgan = require 'morgan'
parser = require 'body-parser'
session = require 'cookie-session'
serve = require 'serve-static'
trace = require 'errorhandler'

# init express, logging and error reporting
app = express()
app.use(trace())
app.use(morgan('dev'))

# add session handler and body parser
app.set('trust proxy', 1)
app.use(session(config.session))
app.use(parser.json())

# TODO: enable csrf protection

# configure views & static files
app.use(serve('./build'))
app.set('views', app.locals.basedir = './views')
app.set('view engine', 'jade')

# load & init middlewares
require('./middlewares')(app)

# load & init handlers
require('./handlers')(app)

# export the app ( for unit testing, etc )
module.exports = app
