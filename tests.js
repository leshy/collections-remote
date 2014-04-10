// Generated by CoffeeScript 1.4.0
(function() {
  var collections, env, express, http, mongodb, rc, rs;

  http = require('http');

  express = require('express');

  mongodb = require('mongodb');

  rs = require('collections-remote/serverside');

  rc = require('collections-remote/clientside');

  collections = require('collections/serverside');

  env = {};

  exports.initHttp = function(test) {
    var app;
    app = env.app = express();
    app.configure(function() {
      app.use(express.cookieParser());
      app.use(express.bodyParser());
      app.use(app.router);
      app.use(function(err, req, res, next) {
        console.log(err.stack);
        env.log('web request error', {
          stack: err.stack
        }, 'error', 'http');
        return res.render('error', {
          ajax: req.query.ajax,
          errorcode: 500,
          errordescription: 'Internal Server Error',
          title: '500',
          details: randomErr()
        });
      });
      env.server = http.createServer(env.app);
      return env.server.listen(8010);
    });
    app.get('*', function(req, res, next) {
      console.log(req);
      return next();
    });
    return test.done();
  };

  exports.initDb = function(test) {
    env.db = new mongodb.Db('test', new mongodb.Server('localhost', 27017), {
      safe: true
    });
    return env.db.open(function() {
      env.collection = new collections.MongoCollection({
        db: env.db,
        collection: 'testc'
      });
      env.smodel = env.collection.defineModel('testmodel', {
        initialize: function() {
          return this.subscribe('create', function(data, callback) {
            return callback(null, {
              x: 'sub change'
            });
          });
        }
      });
      return test.done();
    });
  };

  exports.initServer = function(test) {
    var getRealm;
    getRealm = function(req, callback) {
      return callback(null, {
        admin: true
      });
    };
    env.scol = new rs.CollectionExposerHttpFancy({
      collection: env.collection,
      app: env.app,
      realm: getRealm,
      path: '/api/v1/'
    });
    return test.done();
  };

  exports.initClient = function(test) {
    env.ccol = new rc.RemoteCollectionHttp({
      host: "http://localhost:8010",
      path: "/api/v1/",
      name: 'testc',
      timeout: 1000
    });
    env.cmodel = env.ccol.defineModel('testmodel', {});
    return test.done();
  };

  exports.create = function(test) {
    var x;
    x = new env.cmodel({
      bla: 1
    });
    return x.flush(function(err, data) {
      if (!x.attributes.id) {
        test.fail('no id');
      }
      if (!x.attributes.x) {
        test.fail('no sub change');
      }
      if (!x.attributes.bla) {
        test.fail('no local change');
      }
      return x.remove(function(err, data) {
        var expected;
        expected = {};
        expected[x.attributes.id] = 1;
        test.deepEqual(data, expected);
        return test.done();
      });
    });
  };

  exports.unload = function(test) {
    env.db.close();
    env.server.close();
    return test.done();
  };

}).call(this);
