{User} = require '../../models'

Promise = require 'bluebird'
{expect} = require 'chai'
{Error, Model} = require 'mongoose'


describe 'User', ->
    it 'should be a mongoose model', ->
        expect(User::).to.be.an.instanceof(Model)

    describe '.email', ->
        it 'should be required', ->
            User.createAsync('name': 'John')
            .then (user) ->
                throw new Error('Created user account without an e-mail')
            .catch Error.ValidationError, (err) ->
                expect(err).to.have.deep.property('errors.email.kind', 'required')

        it 'should be unique', ->
            User.createAsync(
                'email': 'john@doe.com'
                'password': '12345678'
                'name': 'John Doe'
            )
            .then ->
                User.createAsync(
                    'email': 'john@doe.com'
                    'password': '12345678'
                    'name': 'John Doe 2'
                )
                .then ->
                    throw new Error('Created user account with duplicate e-mail')
            .catch Error.ValidationError, (err) ->
                expect(err).to.have.deep.property('errors.email.kind', 'unique')

    describe '.password', ->
        it 'should be required', ->
            User.createAsync('name': 'John')
            .then (user) ->
                throw new Error('Created user account without a password')
            .catch Error.ValidationError, (err) ->
                expect(err).to.have.deep.property('errors.password.kind', 'required')

        it 'should be 4 characters minimum', ->
            User.createAsync('password': '123')
            .then (user) ->
                throw new Error('Created user account with a short password')
            .catch Error.ValidationError, (err) ->
                expect(err).to.have.deep.property('errors.password.kind', 'minlength')

        it 'should be hashed automatically on change', ->
            User.createAsync(
                'email': 'john@doe.com'
                'password': '12345678'
                'name': 'John Doe'
            )
            .then (user) ->
                expect(user.password).to.not.equal('12345678')
                expect(user.password).to.have.length.above(50)

        it 'should not be re-hashed if not changed', ->
            oldPassword = null
            User.createAsync(
                'email': 'john@doe.com'
                'password': '12345678'
                'name': 'John Doe'
            )
            .then (user) ->
                oldPassword = user.password
                user.name = 'Forrest Gump'
                user.saveAsync()
            .spread (user) ->
                expect(user.password).to.equal(oldPassword)

    describe '.authenticate', ->
        it 'should accept correct passwords', ->
            User.createAsync(
                'email': 'john@doe.com'
                'password': '12345678'
                'name': 'John Doe'
            )
            .then (user) ->
                user.authenticateAsync('12345678')
            .then (match) ->
                expect(match).to.be.true

        it 'should reject incorrect passwords', ->
            User.createAsync(
                'email': 'john@doe.com'
                'password': '12345678'
                'name': 'John Doe'
            )
            .then (user) ->
                user.authenticateAsync('1234')
            .then (match) ->
                expect(match).to.be.false

    describe '.createdAt', ->
        it 'should not be populated before first save', ->
            user = new User('email': 'test+created@planetary.io')
            expect(user.createdAt).to.not.exist

        it 'should be populated only on the first save', ->
            User.createAsync(
                'email': 'john@doe.com'
                'password': 12345678
                'name': 'test createdAt'
            )
            .then (user) ->
                expect(user.createdAt).to.be.an.instanceof(Date)
                expect(Date.now() - user.createdAt.getTime()).to.be.below(100)
                user.createdAt = new Date().setTime(0)
                user.saveAsync()
            .spread (user) ->
                expect(user.createdAt.getTime()).to.be.equal(0)

    describe '.updatedAt', ->
        it 'should not be populated before first save', ->
            user = new User('email': 'test+created@planetary.io')
            expect(user.updatedAt).to.not.exist

        it 'should be populated on every save', ->
            User.createAsync(
                'email': 'john@doe.com'
                'password': 12345678
                'name': 'test createdAt'
            )
            .then (user) ->
                expect(user.updatedAt).to.be.an.instanceof(Date)
                expect(Date.now() - user.updatedAt.getTime()).to.be.below(100)
                user.updatedAt = new Date().setTime(0)
                user.saveAsync()
            .spread (user) ->
                expect(Date.now() - user.updatedAt.getTime()).to.be.below(100)
