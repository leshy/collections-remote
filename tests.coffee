http = require 'http'
express = require 'express'
mongodb = require 'mongodb'

rs = require 'collections-remote/serverside'
rc = require 'collections-remote/clientside'
collections = require 'collections/serverside'
env = {}

exports.initHttp = (test) ->

    app = env.app = express()
    
    app.configure ->
        app.use express.cookieParser()
        app.use express.bodyParser()
        app.use app.router

        app.use (err, req, res, next) ->
            console.log err.stack
            env.log 'web request error', { stack: err.stack }, 'error', 'http'
            res.render 'error', ajax: req.query.ajax, errorcode: 500, errordescription: 'Internal Server Error', title: '500', details: randomErr()

        env.server = http.createServer env.app
        env.server.listen 8010

    
    test.done()

exports.initDb = (test) ->
    env.db = new mongodb.Db 'test', new mongodb.Server('localhost', 27017), safe: true
    env.db.open ->
        env.collection = new collections.MongoCollection db: env.db, collection: 'testc'
        test.done()

exports.initServer = (test) ->
    getRealm = (req, callback) ->
        callback null, { admin: true }    

    env.smodel = env.collection.defineModel 'testmodel', {}
    
    env.scol = new rs.CollectionExposerHttpFancy collection: env.collection, app: env.app, realm: getRealm, path: '/api/v1/'


    test.done()
    
exports.initClient = (test) ->
    env.ccol = new rc.RemoteCollectionHttp host: "http://localhost:8010", path: "/api/v1/", name: 'testc', timeout: 1000
    env.cmodel = env.ccol.defineModel 'testmodel', {}
    test.done()

exports.create = (test) ->
    x = new env.cmodel bla: 1
    x.flush (err,data) ->
        console.log err,data
        test.done()


exports.unload = (test)->
    env.db.close()
    env.server.close()
    test.done()