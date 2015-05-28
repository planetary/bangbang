{Build, Project} = require '../../models'

expect = require 'expect'
mongoose = require 'mongoose'


describe 'Project', ->
    it 'should be a mongoose model', ->
        expect(Project::).toBeA(mongoose.Model)

    describe '.slug', ->
        it 'should use hints when possible', ->
            Project.createAsync(
                'name': 'test project'
                'slug': 'i-am-a-slug'
            )
            .then (project) ->
                expect(project.slug).toBe('i-am-a-slug')

        it 'should be generated from the name if no hint provided', ->
            Project.createAsync('name': 'test slug')
            .then (project) ->
                expect(project.slug).toBe('test-slug')

        it 'should always be unique', ->
            Project.createAsync('name': 'test unique')
            .then (project) ->
                expect(project.slug).toBe('test-unique')
                Project.createAsync('name': 'test unique')
            .then (project) ->
                expect(project.slug).toNotBe('test-unique')

    describe '.key', ->
        it 'should be automatically generated', ->
            Project.createAsync('name': 'test key')
            .then (project) ->
                expect(project.key).toBeA('string')
                expect(project.key.length).toBeMoreThan(10)

    describe '.regenerate', ->
        project = new Project(
            'name': 'test regenerate'
            'key': 'not-a-generated-key'
        )

        it 'should be callable', ->
            expect(project.regenerate).toBeA('function')

        it 'should generate a new key', ->
            expect(project.key).toBe('not-a-generated-key')
            project.regenerate()
            expect(project.key).toNotBe('not-a-generated-key')

    describe '.remove', ->
        it 'should also remove all builds', ->
            Project.createAsync('name': 'test remove')
            .then (project) ->
                Build.createAsync(
                    'project': project.id
                    'number': project.head++
                )
                .then (build) ->
                    expect(build).toNotBe(null)
                    project.removeAsync()
                    .then ->
                        Build.findOne('_id': build.id)
                    .then (build) ->
                        expect(build).toBe(null)



###    it( 'should correctly collect stats', function() {
        var shares = Math.floor(Math.random() * 10),
            likes =  Math.floor(Math.random() * 10),
            comments =  Math.floor(Math.random() * 10);

        nock( 'http://api.facebook.com' )
            .filteringPath( /\?.*$/g, '' )
            .get( '/restserver.php' )
            .reply( 200, function( url ) {
                var body = qs.parse( url.replace( '/restserver.php?', '' ) );
                expect( body ).toNotBe( null );
                expect( body.urls ).toBe( ACTUAL_PATH );
                expect( body.method ).toBe( 'links.getStats' );
                expect( body.format ).toBe( 'json' ); // others not mocked
                return [ {
                   'url': ACTUAL_PATH,
                   'normalized_url': ACTUAL_PATH,
                   'share_count': shares,
                   'like_count': likes,
                   'comment_count': comments,
                   'total_count': shares + likes + comments,
                   'click_count': 0,
                   'comments_fbid': 1337,
                   'commentsbox_count': 0
                } ];
            } );

        var article = Article( { 'db_pid': ARTICLE_PATH } );

        return task( article ).then( function( stats ) {
            expect( stats ).toNotBe( null );
            expect( stats.shares ).toBe( shares );
            expect( stats.likes ).toBe( likes );
            expect( stats.comments ).toBe( comments );
        } );
    } );


    it( 'should retry before failing on explicit error', function() {
        var tries = 5;
        config.facebook.retryDelay = 0;
        config.facebook.maxAttempts = tries;

        nock( 'http://api.facebook.com' )
            .persist()
            .filteringPath( /\?.*$/g, '' )
            .get( '/restserver.php' )
            .reply( 500, function() { tries -= 1; return ''; } );

        var article = Article( { 'db_pid': ARTICLE_PATH } );

        return task( article ).then( function() {
            throw new Error( 'Did not fail' );
        } ).fail( function() {
            expect( tries ).toBe( -1 );
        } ).fin( function() {
            nock.cleanAll();
        } );
    } );


    it( 'should not retry before failing on implicit error', function() {
        var tries = 5;
        config.facebook.retryDelay = 0;
        config.facebook.maxAttempts = tries;

        nock( 'http://api.facebook.com' )
            .persist()
            .filteringPath( /\?.*$/g, '' )
            .get( '/restserver.php' )
            .reply( 200, function() { tries -= 1; return 'h4x!'; } );

        var article = Article( { 'db_pid': ARTICLE_PATH } );

        return task( article ).then( function() {
            throw new Error( 'Did not fail' );
        } ).fail( function() {
            expect( tries ).toBe( 4 );
        } ).fin( function() {
            nock.cleanAll();
        } );
    } );
} );
###
