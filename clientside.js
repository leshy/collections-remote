// Generated by CoffeeScript 1.4.0
(function() {
  var Backbone, RemoteCollectionHttp, collections, helpers, post;

  Backbone = require('backbone4000');

  collections = require('collections');

  helpers = require('helpers');

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

  RemoteCollectionHttp = exports.RemoteCollectionHttp = Backbone.Model.extend4000(collections.ModelMixin, collections.ReferenceMixin, {
    create: function(data, callback) {
      post(helpers.makePath(this.get('path') + this.get('name'), 'create'), {
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
      post(helpers.makePath(this.get('path') + this.get('name'), 'remove'), {
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
      post(helpers.makePath(this.get('path') + this.get('name'), 'find'), {
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
      post(helpers.makePath(this.get('path') + this.get('name'), 'findOne'), {
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
      post(helpers.makePath(this.get('path') + this.get('name'), 'update'), {
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
    },
    subscribeModel: function() {
      return true;
    },
    unsubscribe: function() {
      return true;
    }
  });

}).call(this);
