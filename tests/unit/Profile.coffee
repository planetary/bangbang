{Profile} = require '../../models'

Promise = require 'bluebird'
{expect} = require 'chai'
{Model, Error} = require 'mongoose'


describe 'Profile', ->
    it 'should be a mongoose model', ->
        expect(Profile::).to.be.an.instanceof(Model)

    describe '.slug', ->
        it 'should be required', ->
            Profile.createAsync('width': 1000)
            .then (profile) ->
                throw new Error('Created profile without a slug')
            .catch Error.ValidationError, (err) ->
                expect(err).to.have.deep.property('errors.slug.kind', 'required')

        it 'should be unique', ->
            Profile.createAsync(
                'slug': 'android'
                'width': 480
                'height': 800
            )
            .then ->
                Profile.createAsync('slug': 'android')
                .then ->
                    throw new Error('Created two profiles with the same slug')
            .catch Error.ValidationError, (err) ->
                expect(err).to.have.deep.property('errors.slug.kind', 'unique')

        it 'should be 4 characters minimum', ->
            Profile.createAsync('slug': 'and')
            .then (user) ->
                throw new Error('Created profile with a short slug')
            .catch Error.ValidationError, (err) ->
                expect(err).to.have.deep.property('errors.slug.kind', 'minlength')

        it 'should not allow non-alphanumeric characters', ->
            Profile.createAsync('slug': '<script type="text/javascript">alert("h4x")</script>')
            .then (user) ->
                throw new Error('Created profile with a short slug')
            .catch Error.ValidationError, (err) ->
                expect(err).to.have.deep.property('errors.slug.kind', 'regexp')

    describe '.jsonify', ->
        it 'should be a function', ->
            profile = new Profile()
            expect(profile.jsonify).to.be.a('function')

        it 'should include the width and height', ->
            spec = new Profile(
                'name': 'apple watch'
                'width': 128
                'height': 128
            ).jsonify()
            expect(spec).to.have.property('width', 128)
            expect(spec).to.have.property('height', 128)

        it 'should include the agent, when available', ->
            spec = new Profile(
                'name': 'apple watch'
                'width': 128
                'height': 128
                'agent': 'watchOS'
            ).jsonify()
            expect(spec).to.have.deep.property('agent', 'watchOS')

    describe '.createdAt', ->
        it 'should not be populated before first save', ->
            profile = new Profile(
                'slug': 'iphone'
                'width': 320
                'height': '480'
            )
            expect(profile.createdAt).to.not.exist

        it 'should be populated only on the first save', ->
            Profile.createAsync(
                'slug': 'iphone'
                'width': 320
                'height': '480'
            )
            .then (profile) ->
                expect(profile.createdAt).to.be.an.instanceof(Date)
                expect(Date.now() - profile.createdAt.getTime()).to.be.below(100)
                profile.createdAt = new Date().setTime(0)
                profile.saveAsync()
            .spread (profile) ->
                expect(profile.createdAt.getTime()).to.be.equal(0)

    describe '.updatedAt', ->
        it 'should not be populated before first save', ->
            profile = new Profile(
                'slug': 'iphone'
                'width': 320
                'height': '480'
            )
            expect(profile.updatedAt).to.not.exist

        it 'should be populated on every save', ->
            Profile.createAsync(
                'slug': 'iphone'
                'width': 320
                'height': '480'
            )
            .then (profile) ->
                expect(profile.updatedAt).to.be.an.instanceof(Date)
                expect(Date.now() - profile.updatedAt.getTime()).to.be.below(100)
                profile.updatedAt = new Date().setTime(0)
                profile.saveAsync()
            .spread (profile) ->
                expect(Date.now() - profile.updatedAt.getTime()).to.be.below(100)
