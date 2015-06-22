config = require './config'

csrf = require 'csurf'
express = require 'express'
morgan = require 'morgan'
parser = require 'body-parser'
session = require 'cookie-session'

# init express & body parser
app = express()
app.use(express.static('./build'))
app.use(parser.json())
app.use(morgan('dev'))

app.use(session(config.session))

# load & init middlewares
require('./middlewares')(app)

# load & init handlers
require('./handlers')(app)

# export the app ( for unit testing, etc )
module.exports = app
