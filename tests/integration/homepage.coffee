request = require 'supertest'
app = require '../../app'


describe 'homepage', ->
    it 'should be 200', (next) ->
        request(app)
            .get('/')
            .expect(200)
            .end(next)
