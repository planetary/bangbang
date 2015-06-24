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

    describe '.createdAt', ->
        it 'should not be populated before first save', ->
            project = new Project('name': 'test createdAt')
            expect(project.createdAt).to.not.exist

        it 'should be populated only on the first save', ->
            Project.createAsync('name': 'test createdAt')
            .then (project) ->
                expect(project.createdAt).to.be.an.instanceof(Date)
                expect(Date.now() - project.createdAt.getTime()).to.be.below(100)
                project.createdAt = new Date().setTime(0)
                project.saveAsync()
            .spread (project) ->
                expect(project.createdAt.getTime()).to.be.equal(0)

    describe '.updatedAt', ->
        it 'should not be populated before first save', ->
            project = new Project('name': 'test updatedAt')
            expect(project.updatedAt).to.not.exist

        it 'should be populated on every save', ->
            Project.createAsync('name': 'test updatedAt')
            .then (project) ->
                expect(project.updatedAt).to.be.an.instanceof(Date)
                expect(Date.now() - project.updatedAt.getTime()).to.be.below(100)
                project.updatedAt = new Date().setTime(0)
                project.saveAsync()
            .spread (project) ->
                expect(Date.now() - project.updatedAt.getTime()).to.be.below(100)
