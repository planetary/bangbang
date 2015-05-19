express = require 'express'
morgan = require 'morgan'
parser = require 'body-parser'

# init express & body parser
app = express()
app.use(parser.json())
app.use(morgan('dev'))


# load & init middlewares
require('./middlewares')(app)

# load & init handlers
require('./handlers')(app)

# export the app ( for unit testing, etc )
module.exports = app
