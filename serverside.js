// Generated by LiveScript 1.4.0
(function(){
  var helpers, Backbone, _, async, Validator, v, Select, subscriptionMan, callbackToRes, errDataToRes, CollectionExposerHttpRaw, CollectionExposerHttpFancy, CollectionExposerGeneric;
  helpers = require('helpers');
  Backbone = require('backbone4000');
  _ = require('underscore');
  async = require('async');
  Validator = require('validator2-extras');
  v = Validator.v;
  Select = Validator.Select;
  subscriptionMan = require('subscriptionman2');
  callbackToRes = function(res){
    return function(err, data){
      if (err != null && err.name) {
        err = err.name;
      }
      return res.end(JSON.stringify({
        err: err,
        data: data
      }));
    };
  };
  errDataToRes = function(res, err, data){
    if (err != null && err.name) {
      err = err.name;
    }
    return res.end(JSON.stringify({
      err: err,
      data: data
    }));
  };
  CollectionExposerHttpRaw = exports.CollectionExposerHttpRaw = Validator.ValidatedModel.extend4000({
    validator: {
      path: 'String',
      app: 'Function',
      collection: 'Instance'
    },
    initialize: function(){
      var path, app, c, name;
      path = this.get('path');
      app = this.get('app');
      c = this.get('collection');
      name = c.get('name');
      app.post(helpers.makePath(path, name, 'create'), function(req, res){
        return c.create(req.body.data, callbackToRes(res));
      });
      app.post(helpers.makePath(path, name, 'remove'), function(req, res){
        return c.remove(req.body.pattern, callbackToRes(res));
      });
      app.post(helpers.makePath(path, name, 'update'), function(req, res){
        return c.update(req.body.pattern, req.body.data, callbackToRes(res));
      });
      app.post(helpers.makePath(path, name, 'findOne'), function(req, res){
        return c.findOne(req.body.pattern, function(err, data){
          return errDataToRes(res, err, data);
        });
      });
      app.post(helpers.makePath(path, name, 'call'), function(req, res){
        return c.fcall(req.body['function'], req.body.args || [], req.body.pattern, undefined, function(err, data){
          return errDataToRes(res, err, data);
        });
      });
      return app.post(helpers.makePath(path, name, 'find'), function(req, res){
        var reslist;
        reslist = [];
        return c.find(req.body.pattern, req.body.limits, function(err, data){
          return reslist.push(data);
        }, function(){
          return res.end(JSON.stringify(reslist));
        });
      });
    }
  });
  CollectionExposerHttpFancy = exports.CollectionExposerHttpFancy = Validator.ValidatedModel.extend4000({
    validator: {
      path: 'String',
      app: 'Function',
      collection: 'Instance',
      realm: v().or('Object', 'String', 'Function')
    },
    initialize: function(){
      var path, app, c, name, realm, getRealm, this$ = this;
      path = this.get('path');
      app = this.get('app');
      c = this.get('collection');
      name = c.get('name');
      realm = this.get('realm');
      getRealm = function(req){
        if (realm.constructor !== Function) {
          return realm;
        } else {
          return realm(req);
        }
      };
      app.post(helpers.makePath(path, name, 'create'), function(req, res){
        return c.rCreate(getRealm(req), req.body, callbackToRes(res));
      });
      app.post(helpers.makePath(path, name, 'remove'), function(req, res){
        return c.rRemove(getRealm(req), req.body, callbackToRes(res));
      });
      app.post(helpers.makePath(path, name, 'update'), function(req, res){
        return c.rUpdate(getRealm(req), req.body, callbackToRes(res));
      });
      app.post(helpers.makePath(path, name, 'find'), function(req, res){
        var first;
        res.write("[");
        first = true;
        return c.rFind(getRealm(req), req.body, function(err, model){
          if (!first) {
            res.write(",\n");
          } else {
            first = false;
          }
          return res.write(JSON.stringify(model));
        }, function(){
          return res.end("]");
        });
      });
      app.post(helpers.makePath(path, name, 'findOne'), function(req, res){
        return c.rFindOne(getRealm(req), req.body, callbackToRes(res));
      });
      return app.post(helpers.makePath(path, name, 'call'), function(req, res){
        return c.rCall(getRealm(req), req.body, callbackToRes(res));
      });
    }
  });
  CollectionExposerGeneric = exports.CollectionExposerGeneric = Validator.ValidatedModel.extend4000({
    validator: {
      collection: 'Instance'
    },
    initialize: function(){
      var callbackToRes, c, this$ = this;
      callbackToRes = function(res){
        return function(err, data){
          if (err != null && err.name) {
            err = err.name;
          }
          return res.end({
            err: err,
            data: data
          });
        };
      };
      c = this.get('collection');
      this.subscribe({
        create: Object
      }, function(msg, res, realm){
        return c.createModel(msg.create, realm, callbackToRes(res));
      });
      this.subscribe({
        remove: Object
      }, function(msg, res, realm){
        return c.removeModel(msg.remove, realm, callbackToRes(res));
      });
      this.subscribe({
        update: Object,
        data: Object
      }, function(msg, res, realm){
        return c.updateModel(msg.update, msg.data, realm, callbackToRes(res));
      });
      this.subscribe({
        findOne: Object
      }, function(msg, res, realm){
        return c.findModel(msg.findOne, realm, callbackToRes(res));
      });
      this.subscribe({
        call: String,
        args: v()['default']([]).Array()
      }, function(msg, res, realm){
        return c.fcall(msg.call, msg.args, realm, callbackToRes(res));
      });
      return this.subscribe({
        find: Object
      }, function(msg, res, realm){
        var bucket, endCb;
        bucket = new helpers.parallelBucket();
        endCb = bucket.cb();
        c.findModels(msg.find, msg.limits || {}, function(err, model){
          var bucketCallback;
          bucketCallback = bucket.cb();
          return model.render(realm, function(err, data){
            if (!err) {
              res.write(data);
            }
            return bucketCallback();
          });
        }, function(err, data){
          return endCb();
        });
        return bucket.done(err, data)(function(){
          return res.end();
        });
      });
    }
  });
}).call(this);
