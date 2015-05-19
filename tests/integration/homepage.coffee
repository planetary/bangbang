request = require 'supertest'
app = require '../../app'


describe 'homepage', ->
    it 'should be 404', (next) ->
        request(app)
            .get('/')
            .expect(404)
            .end(next)
