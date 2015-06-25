{Build, Project, Screenshot} = require '../../models'

Promise = require 'bluebird'
{expect} = require 'chai'
{Model, Error} = require 'mongoose'


describe 'Build', ->
    it 'should be a mongoose model', ->
        expect(Build::).to.be.an.instanceof(Model)


    describe '.project', ->
        it 'should be required', ->
            Build.createAsync({})
            .then (build) ->
                throw new Error('Created build without a project')
            .catch Error.ValidationError, (err) ->
                expect(err).to.have.deep.property('errors.project.kind', 'required')


    describe '.remove', ->
        it 'should also remove all screenshots', ->
            Project.createAsync('name': 'test')
            .then (project) ->
                Build.createAsync(
                    'project': project.id
                    'number': project.head++
                )
                .then (build) ->
                    Promise.fromNode (next) -> Screenshot.collection.insert(
                        'project': project.id
                        'build': build.number
                        'slug': 'test-screenshot-slug'
                        'target': 'http://google.ro'
                        'delay': 0
                        'format': 'jpeg'
                        'profiles': [
                            'slug': 'test'
                            'width': 1000
                            'height': 750
                            'agent': 'Googlebot'
                        ]
                    , next)
                    .then (screenshot) ->
                        expect(screenshot).to.exist
                        build.removeAsync()
                        .then ->
                            Screenshot.findOneAsync('_id': screenshot._id)
                        .then (screenshot) ->
                            expect(screenshot).to.not.exist


    describe '.jsonify', ->
        it 'should be a function', ->
            build = new Build()
            expect(build.jsonify).to.be.a('function')

        it 'should include the build number', ->
            build = new Build('number': 5)
            expect(build.jsonify()).to.have.property('number', 5)

        it 'should include user-defined metadata', ->
            build = new Build('meta': 'theAnswer': 42)
            expect(build.jsonify()).to.have.deep.property('meta.theAnswer', 42)


    describe '.createdAt', ->
        it 'should not be populated before first save', ->
            Project.createAsync('name': 'test createdAt')
            .then (project) ->
                build = new Build(
                    'project': project
                    'number': project.head++
                )
                expect(build.createdAt).to.not.exist

        it 'should be populated only on the first save', ->
            Project.createAsync('name': 'test createdAt')
            .then (project) ->
                Build.createAsync(
                    'project': project
                    'number': project.head++
                )
            .then (build) ->
                expect(build.createdAt).to.be.an.instanceof(Date)
                expect(Date.now() - build.createdAt.getTime()).to.be.below(100)
                build.createdAt = new Date().setTime(0)
                build.saveAsync()
            .spread (build) ->
                expect(build.createdAt.getTime()).to.be.equal(0)


    describe '.updatedAt', ->
        it 'should not be populated before first save', ->
            Project.createAsync('name': 'test updatedAt')
            .then (project) ->
                build = new Build(
                    'project': project
                    'number': project.head++
                )
                expect(build.updatedAt).to.not.exist

        it 'should be populated on every save', ->
            Project.createAsync('name': 'test')
            .then (project) ->
                Build.createAsync(
                    'project': project
                    'number': project.head++
                )
            .then (build) ->
                expect(build.updatedAt).to.be.an.instanceof(Date)
                expect(Date.now() - build.updatedAt.getTime()).to.be.below(100)
                build.updatedAt = new Date().setTime(0)
                build.saveAsync()
            .spread (build) ->
                expect(Date.now() - build.updatedAt.getTime()).to.be.below(100)
