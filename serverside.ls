helpers = require 'helpers'
Backbone = require 'backbone4000'  
_ = require 'underscore'
async = require 'async'
Validator = require 'validator2-extras'; v = Validator.v; Select = Validator.Select

subscriptionMan = require('subscriptionman2')

callbackToRes = (res) -> (err,data) ->
  if err?.name then err = err.name
  res.end JSON.stringify err: err, data: data
  
errDataToRes = (res,err,data) ->
  if err?.name then err = err.name
  res.end JSON.stringify( err: err, data: data )

# exposes a collection via HTTP (express)
CollectionExposerHttpRaw = exports.CollectionExposerHttpRaw = Validator.ValidatedModel.extend4000 do
  validator:
    path: 'String',
    app: 'Function',
    collection: 'Instance'

  initialize: ->     
    path = @get 'path'
    app = @get 'app'
    c = @get 'collection'
    name = c.get 'name'

    app.post helpers.makePath(path, name, 'create'), (req,res) ->
      c.create req.body.data, callbackToRes(res)
      
    app.post helpers.makePath(path, name, 'remove'), (req,res) -> 
      c.remove req.body.pattern, callbackToRes(res)
      
    app.post helpers.makePath(path, name, 'update'), (req,res) -> 
      c.update req.body.pattern, req.body.data, callbackToRes(res)
      
    app.post helpers.makePath(path, name, 'findOne'), (req,res) -> 
      c.findOne req.body.pattern, (err,data) -> errDataToRes res, err, data
      
    app.post helpers.makePath(path, name, 'call'), (req,res) ->
      c.fcall req.body.function, (req.body.args or []), req.body.pattern, undefined, (err,data) ->
        errDataToRes res, err, data
        
    app.post helpers.makePath(path, name, 'find'), (req,res) -> 
      reslist = []
      c.find( req.body.pattern, req.body.limits,
        (err,data) -> reslist.push(data)
        -> res.end JSON.stringify(reslist) )

CollectionExposerHttpFancy = exports.CollectionExposerHttpFancy = Validator.ValidatedModel.extend4000 do
  validator:
    path: 'String',
    app: 'Function',
    collection: 'Instance'
    realm: v().or('Object', 'String', 'Function')
    
  initialize: ->
    path = @get 'path'
    app = @get 'app'
    c = @get 'collection'
    name = c.get 'name'
    realm = @get 'realm'

    getRealm = (req) ->
      if realm.constructor isnt Function then return realm
      else return realm req
    
    app.post helpers.makePath(path, name, 'create'), (req,res) ->
      c.rCreate getRealm(req), req.body, callbackToRes(res)
      
    app.post helpers.makePath(path, name, 'remove'), (req,res) ->
      c.rRemove getRealm(req), req.body, callbackToRes(res)
      
    app.post helpers.makePath(path, name, 'update'), (req,res) ->
      c.rUpdate getRealm(req), req.body, callbackToRes(res)
          
    app.post helpers.makePath(path, name, 'find'), (req,res) ~>
      reslist = []
      c.rFind(req.body, ((err,model) -> reslist.push(model))
        -> res.end JSON.stringify(reslist))

    app.post helpers.makePath(path, name, 'findOne'), (req,res) ->
      c.rFindOne getRealm(req), req.body, callbackToRes(res)
      
    app.post helpers.makePath(path, name, 'call'), (req,res) ->
      c.rCall getRealm(req), req.body, callbackToRes(res)

    


                  
# inherit subscriptionman, check subsman2 and make sure it fits here..    
CollectionExposerGeneric = exports.CollectionExposerGeneric = Validator.ValidatedModel.extend4000 do
  validator:
    collection: 'Instance'

  initialize: ->
    callbackToRes = (res) -> (err,data) ->
      if err?.name then err = err.name
      res.end err: err, data: data
      
    c = @get 'collection'
    
    @subscribe { create: Object }, (msg, res, realm) ->
      c.createModel msg.create, realm, callbackToRes(res)
      
    @subscribe { remove: Object }, (msg, res, realm) ->
      c.removeModel msg.remove, realm, callbackToRes(res)
      
    @subscribe { update: Object, data: Object }, (msg, res, realm) ->
      c.updateModel msg.update, msg.data, realm, callbackToRes(res)
      
    @subscribe { findOne: Object }, (msg, res, realm) ->
      c.findModel msg.findOne, realm, callbackToRes(res)
      
    @subscribe { call: String, args: v().default([]).Array() }, (msg, res, realm) ->
      c.fcall msg.call, msg.args, realm, callbackToRes(res)
      
    @subscribe { find: Object }, (msg, res, realm) ~>
      bucket = new helpers.parallelBucket()
      endCb = bucket.cb()
            
      c.findModels msg.find, (msg.limits or {}), ((err,model) ->
        bucketCallback = bucket.cb()
        model.render realm, (err,data) ->
          if not err then res.write data
          bucketCallback()), ((err,data) -> endCb())
          
      bucket.done(err,data) -> res.end()  
