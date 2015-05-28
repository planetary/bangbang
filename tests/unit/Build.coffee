{Build, Project, Screenshot} = require '../../models'

Promise = require 'bluebird'
expect = require 'expect'
mongoose = require 'mongoose'


describe 'Build', ->
    it 'should be a mongoose model', ->
        expect(Build::).toBeA(mongoose.Model)

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
                        expect(screenshot).toNotBe(null)
                        build.removeAsync()
                        .then ->
                            Screenshot.findOne('_id': screenshot._id)
                        .then (screenshot) ->
                            expect(screenshot).toBe(null)
