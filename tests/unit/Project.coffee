{Build, Project} = require '../../models'

{expect} = require 'chai'
{Model, Error} = require 'mongoose'


describe 'Project', ->
    it 'should be a mongoose model', ->
        expect(Project::).to.be.an.instanceof(Model)

    describe '.name', ->
        it 'should be required', ->
            Project.createAsync('key': '1234')
            .then (project) ->
                throw new Error('Created nameless project')
            .catch Error.ValidationError, (err) ->
                expect(err).to.have.deep.property('errors.name.kind', 'required')

    describe '.slug', ->
        it 'should use hints when possible', ->
            Project.createAsync(
                'name': 'test project'
                'slug': 'i-am-a-slug'
            )
            .then (project) ->
                expect(project.slug).to.equal('i-am-a-slug')

        it 'should be generated from the name if no hint provided', ->
            Project.createAsync('name': 'test slug')
            .then (project) ->
                expect(project.slug).to.equal('test-slug')

        it 'should always be unique', ->
            Project.createAsync('name': 'test unique')
            .then (project) ->
                expect(project.slug).to.equal('test-unique')
                Project.createAsync('name': 'test unique')
            .then (project) ->
                expect(project.slug).to.not.equal('test-unique')

    describe '.key', ->
        it 'should be automatically generated', ->
            Project.createAsync('name': 'test key')
            .then (project) ->
                expect(project.key).to.be.a('string')
                expect(project.key).to.have.length.above(10)

    describe '.regenerate', ->
        project = new Project(
            'name': 'test regenerate'
            'key': 'not-a-generated-key'
        )

        it 'should be callable', ->
            expect(project.regenerate).to.be.a('function')

        it 'should generate a new key', ->
            expect(project.key).to.equal('not-a-generated-key')
            project.regenerate()
            expect(project.key).to.not.equal('not-a-generated-key')

    describe '.remove', ->
        it 'should also remove all builds', ->
            Project.createAsync('name': 'test remove')
            .then (project) ->
                Build.createAsync(
                    'project': project.id
                    'number': project.head++
                )
                .then (build) ->
                    expect(build).to.exist
                    project.removeAsync()
                    .then ->
                        Build.findOneAsync('_id': build.id)
                    .then (build) ->
                        expect(build).to.not.exist
