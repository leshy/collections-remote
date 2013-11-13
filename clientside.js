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
      post(helpers.makePath(this.get('path'), 'create'), {
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
      post(helpers.makePath(this.get('path'), 'remove'), {
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
    find: function(pattern, limits, callback) {
      if (pattern == null) {
        pattern = {};
      }
      if (limits == null) {
        limits = {};
      }
      post(helpers.makePath(this.get('path'), 'find'), {
        pattern: pattern,
        limits: limits
      }, function(err, res) {
        if (!err) {
          return callback(void 0, res);
        } else {
          return callback(err, res);
        }
      });
      return void 0;
    },
    findOne: function(pattern, callback) {
      if (pattern == null) {
        pattern = {};
      }
      post(helpers.makePath(this.get('path'), 'findOne'), {
        pattern: pattern
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

  /*                
      _create: (entry,callback) -> core.msgCallback @send( collection: @get('name'), create: entry ), callback
      
      _remove: (pattern,callback) -> core.msgCallback @send( collection: @get('name'), remove: pattern, raw: true ), callback
      
      _update: (pattern,data,callback) -> core.msgCallback @send( collection: @get('name'), update: pattern, data: data, raw: true ), callback
      
  
      _findOne: (pattern,callback) ->
          reply = @send( collection: @get('name'), findOne: pattern )
          reply.read (msg) -> if msg then callback(undefined,msg.data) else callback("not found")
  
      _fcall: (name, args, pattern, callback) ->
          reply = @send( collection: @get('name'), call: name, args: args, data: pattern )
          reply.read (msg) -> if msg then helpers.cbc callback, msg.err, msg.data;
  */


}).call(this);
