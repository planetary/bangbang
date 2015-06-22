Promise = require 'bluebird'
request = require 'superagent'


class KeplerError extends Error
    constructor: (code, message, data) ->
        @code = code
        @message = message
        @data = data
        super

    @fromResponseBody = (body) ->
        if body.code is 'VALIDATION'
            ErrorClass = ValidationError
        else if body.code is 'FORBIDDEN'
            ErrorClass = ForbiddenError
        else if body.code is 'NOT_FOUND'
            ErrorClass = NotFoundError
        else if body.code is 'INTERNAL'
            ErrorClass = InternalError
        else
            ErrorClass = KeplerError
        new ErrorClass(body.code, body.message, body.data)


class ValidationError extends KeplerError
    # Thrown for mongoose validation errors; contains more info in the `data` attribute


class ForbiddenError extends KeplerError
    # Thrown whenever the current user does not have sufficient privileges to perform a server call


class NotFoundError extends KeplerError
    # Thrown whenever an inexistent resource is accessed; in some cases will be returned by
    # existing resources that the current user does not have access to


class InternalError extends KeplerError
    # Thrown when the server is in trouble or in case of a bug


call = (method, url, body) ->
    new Promise (resolve, reject) ->
        request(method, url)
            .send(body)
            .accept('json')
            .end (err, res) ->
                if res.body.code is 'OK'
                    # looking good (data may or may not be present)
                    resolve(res.body.data)
                else if res.body.code
                    # server error; cast into kepler error and raise
                    reject(KeplerError.fromResponseBody(res.body))
                else if err
                    # http error; reject directly
                    reject(err)
                else
                    # unknown
                    reject(new InternalError('INTERNAL', 'An unknown error has ocurred while
                                                          communicating to the server'))


module.exports =
    # public interface
    'call': call
    'get': (url) -> call('GET', url)
    'post': (url, body) -> call('POST', url, body)
    'put': (url, body) -> call('PUT', url, body)
    'delete': (url) -> call('DELETE', url)
    # error handling
    'Error': KeplerError
    'KeplerError': KeplerError
    'ValidationError': ValidationError
    'ForbiddenError': ForbiddenError
    'NotFoundError': NotFoundError
    'InternalError': InternalError
