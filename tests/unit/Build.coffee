{Build, Project, Screenshot} = require '../../models'

Promise = require 'bluebird'
{expect} = require 'chai'
{Model} = require 'mongoose'


describe 'Build', ->
    it 'should be a mongoose model', ->
        expect(Build::).to.be.an.instanceof(Model)

    describe '.remove', ->
        it 'should also remove all screenshots', ->
            Project.createAsync('name': 'test build')
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
