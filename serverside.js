// Generated by CoffeeScript 1.4.0
(function() {
  var Backbone, CollectionExposerHttpFancy, CollectionExposerHttpRaw, async, helpers, _;

  helpers = require('helpers');

  Backbone = require('backbone4000');

  _ = require('underscore');

  async = require('async');

  CollectionExposerHttpRaw = exports.CollectionExposerHttpRaw = Backbone.Model.extend4000({
    initialize: function() {
      var app, c, callbackToRes, name, path,
        _this = this;
      path = this.get('path');
      app = this.get('app');
      c = this.get('collection');
      name = c.get('name');
      callbackToRes = function(res) {
        return function(err, data) {
          return res.end(JSON.stringify({
            err: err,
            data: data
          }));
        };
      };
      app.post(helpers.makePath(path, name, 'create'), function(req, res) {
        return c.create(req.body.data, callbackToRes(res));
      });
      app.post(helpers.makePath(path, name, 'remove'), function(req, res) {
        return c.remove(req.body.pattern, callbackToRes(res));
      });
      app.post(helpers.makePath(path, name, 'update'), function(req, res) {
        return c.update(req.body.pattern, req.body.data, callbackToRes(res));
      });
      app.post(helpers.makePath(path, name, 'find'), function(req, res) {
        var reslist;
        reslist = [];
        return c.find(req.body.pattern, req.body.limits, function(err, data) {
          return reslist.push(data);
        }, function() {
          return res.end(JSON.stringify(reslist));
        });
      });
      app.post(helpers.makePath(path, name, 'findOne'), function(req, res) {
        return c.findOne(req.body.pattern, function(err, data) {
          return res.end(JSON.stringify({
            err: err,
            data: data
          }));
        });
      });
      return app.post(helpers.makePath(path, name, 'call'), function(req, res) {
        return c.fcall(req.body["function"], req.body.args || [], req.body.pattern, void 0, function(err, data) {
          return res.end(JSON.stringify({
            err: err,
            data: data
          }));
        });
      });
    }
  });

  CollectionExposerHttpFancy = exports.CollectionExposerHttpFancy = Backbone.Model.extend4000({
    initialize: function() {
      var app, c, callbackToRes, name, path,
        _this = this;
      path = this.get('path');
      app = this.get('app');
      c = this.get('collection');
      name = c.get('name');
      callbackToRes = function(res) {
        return function(err, data) {
          return res.end(JSON.stringify({
            err: err,
            data: data
          }));
        };
      };
      app.post(helpers.makePath(path, name, 'create'), function(req, res) {
        return c.createModel(req.body.data, callbackToRes(res));
      });
      app.post(helpers.makePath(path, name, 'remove'), function(req, res) {
        return c.removeModel(req.body.pattern, callbackToRes(res));
      });
      app.post(helpers.makePath(path, name, 'update'), function(req, res) {
        return c.updateModel(req.body.pattern, req.body.data, callbackToRes(res));
      });
      app.post(helpers.makePath(path, name, 'find'), function(req, res) {
        var reslist;
        reslist = [];
        return c.findModels(req.body.pattern, req.body.limits, function(err, model) {
          return reslist.push(model);
        }, function() {
          var flist;
          flist = _.map(reslist, function(model) {
            return function(callback) {
              return model.render(req, callback);
            };
          });
          return async.parallel(flist, function(err, data) {
            return res.end(JSON.stringify(data));
          });
        });
      });
      app.post(helpers.makePath(path, name, 'findOne'), function(req, res) {
        return c.findModel(req.body.pattern, function(err, model) {
          if (err || !model) {
            return res.end(JSON.stringify({
              err: err,
              data: model
            }));
          }
          return model.render(req, function(err, data) {
            return res.end(JSON.stringify({
              err: err,
              data: data
            }));
          });
        });
      });
      return app.post(helpers.makePath(path, name, 'call'), function(req, res) {
        return c.fcall(req.body["function"], req.body.args || [], req.body.pattern, void 0, function(err, data) {
          return res.end(JSON.stringify({
            err: err,
            data: data
          }));
        });
      });
    }
  });

}).call(this);
