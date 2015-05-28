config = require '../config'

async = require 'async'
aws = require 'aws-sdk'
Promise = require 'bluebird'
base64 = require 'base64-stream'
child = require 'child_process'
path = require 'path'


s3 = new aws.S3(
    'apiVersion': '2006-03-01'
    'region': config.aws.region
)


queue = async.queue((request, next) ->
    # captures a screenshot of `request.url` and uploads it directly to the pre-configured AWS
    # bucket under `request.key`. Concurrency-limited.
    async.auto({
        'phantom': (next) ->
            # spawn child process and feed it input
            phantom = child.spawn(
                config.screenshots.phantom
                [path.join( __dirname, 'capture.phantom.js' )]
                {'stdio': ['pipe', 'pipe', 'ignore']}
            )
            phantom.stdin.end(JSON.stringify(request))

            next(null, phantom)
        'wait': ['phantom', (next, ctx) ->
            # wait for the process to end, helping it if necessary http://bit.ly/1B4ToFb
            timer = setTimeout(
                -> ctx.phantom.kill(9)
                config.screenshots.timeout
            )

            ctx.phantom.on 'close', (code) ->
                clearTimeout(timer)
                if code
                    return next(new Error("Child process crashed with #{code}"))
                next()
        ]
        'upload': ['phantom', (next, ctx) ->
            s3.upload({
                'ACL': 'public-read'
                'Bucket': config.aws.bucket
                'Key': request.key
                'Body': ctx.phantom.stdout.pipe(base64.decode())
                'ContentType': "image/#{request.format}"
                'StorageClass': if config.aws.reliable then 'STANDARD' else 'REDUCED_REDUNDANCY'
            }, next)
        ]
    }, next)
, config.screenshots.concurrency)


module.exports = (request) ->
    new Promise (resolve, reject) ->
        queue.push request, (err, result) ->
            if err
                return reject(err)
            resolve()
