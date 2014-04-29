// Generated by CoffeeScript 1.4.0
(function() {
  var Backbone, RemoteCollectionHttp, collections, helpers, post, req, request;

  Backbone = require('backbone4000');

  collections = require('collections');

  helpers = require('helpers');

  if (!window) {
    req = 'request';
    request = require(req);
    post = function(url, data, callback) {
      var options;
      options = {
        url: url,
        method: "POST",
        json: data
      };
      return request(options, function(err, req, data) {
        return callback(err, data);
      });
    };
  } else {
    post = function(url, data, callback) {
      return $.ajax(url, {
        type: "POST",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(data),
        success: function(data) {
          return callback(void 0, data);
        },
        error: function(xhr, status, err) {
          return callback(status);
        }
      });
    };
  }

  RemoteCollectionHttp = exports.RemoteCollectionHttp = Backbone.Model.extend4000({
    getpath: function(query) {
      var host, path;
      path = helpers.makePath(this.get('path') + this.get('name'), query);
      if (!(host = this.get('host'))) {
        return path;
      } else {
        return host + path;
      }
    },
    create: function(data, callback) {
      post(this.getpath('create'), {
        data: data
      }, function(err, res) {
        if (!err) {
          return callback(res.err, res.data);
        } else {
          return callback(err, res);
        }
      });
      return void 0;
    },
    remove: function(pattern, callback) {
      post(this.getpath('remove'), {
        pattern: pattern
      }, function(err, res) {
        if (!err) {
          return callback(res.err, res.data);
        } else {
          return callback(err, res);
        }
      });
      return void 0;
    },
    find: function(pattern, limits, callback, callbackDone) {
      if (pattern == null) {
        pattern = {};
      }
      if (limits == null) {
        limits = {};
      }
      post(this.getpath('find'), {
        pattern: pattern,
        limits: limits
      }, function(err, res) {
        if (err) {
          callback(err, void 0);
        }
        _.map(res, function(element) {
          return callback(void 0, element);
        });
        return helpers.cbc(callbackDone);
      });
      return void 0;
    },
    findOne: function(pattern, callback) {
      if (pattern == null) {
        pattern = {};
      }
      post(this.getpath('findOne'), {
        pattern: pattern
      }, function(err, res) {
        if (!err) {
          return callback(res.err, res.data);
        } else {
          return callback(err, res);
        }
      });
      return void 0;
    },
    update: function(pattern, data, callback) {
      post(this.getpath('update'), {
        pattern: pattern,
        data: data
      }, function(err, res) {
        if (!err) {
          return callback(res.err, res.data);
        } else {
          return callback(err, res);
        }
      });
      return void 0;
    }
  });

  RemoteCollectionHttp = exports.RemoteCollectionHttp = RemoteCollectionHttp.extend4000(collections.ReferenceMixin, collections.ModelMixin, collections.RequestIdMixin, collections.CachingMixin);

}).call(this);
