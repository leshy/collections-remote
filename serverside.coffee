helpers = require 'helpers'
Backbone = require 'backbone4000'    
_ = require 'underscore'
async = require 'async'
Validator = require 'validator2-extras'; v = Validator.v; Select = Validator.Select

callbackToRes = (res) -> (err,data) ->
    if err?.name then err = err.name
    res.end JSON.stringify err: err, data: data
    
errDataToRes = (res,err,data) ->
    if err?.name then err = err.name
    res.end JSON.stringify( err: err, data: data )

# exposes a collection via HTTP (express)
CollectionExposerHttpRaw = exports.CollectionExposerHttpRaw = Validator.ValidatedModel.extend4000
    validator:
        path: 'String',
        app: 'Function',
        collection: 'Instance'

    initialize: ->       
        path = @get 'path'
        app = @get 'app'
        c = @get 'collection'
        name = c.get 'name'

        app.post helpers.makePath(path, name, 'create'), (req,res) -> c.create req.body.data, callbackToRes(res)
        app.post helpers.makePath(path, name, 'remove'), (req,res) => c.remove req.body.pattern, callbackToRes(res)
        app.post helpers.makePath(path, name, 'update'), (req,res) => c.update req.body.pattern, req.body.data, callbackToRes(res)
        
        app.post helpers.makePath(path, name, 'find'), (req,res) =>
            reslist = []
            c.find( req.body.pattern, req.body.limits,
                (err,data) -> reslist.push(data)
                () -> res.end JSON.stringify(reslist) )

        app.post helpers.makePath(path, name, 'findOne'), (req,res) => c.findOne req.body.pattern, (err,data) ->
            errDataToRes res, err, data

        app.post helpers.makePath(path, name, 'call'), (req,res) -> c.fcall req.body.function, req.body.args or [], req.body.pattern, undefined, (err,data) ->
            errDataToRes res, err, data


CollectionExposerHttpFancy = exports.CollectionExposerHttpFancy = Validator.ValidatedModel.extend4000
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

        getRealm = (req, callback) ->
            if realm.constructor isnt Function then return callback null, realm
            realm req, callback
        
        app.post helpers.makePath(path, name, 'create'), (req,res) -> 
            c.createModel req.body.data, callbackToRes(res)
        
        app.post helpers.makePath(path, name, 'remove'), (req,res) -> 
            c.removeModel req.body.pattern, callbackToRes(res)
        
        app.post helpers.makePath(path, name, 'update'), (req,res) =>
            getRealm req, (err, realm) ->
                if err then return res.end JSON.stringify err: err, data: data

                c.updateModel req.body.pattern, req.body.data, realm, (err,data) -> errDataToRes res,err,data
                    
        app.post helpers.makePath(path, name, 'find'), (req,res) =>
            reslist = []
            
            verbose = false
            
            if req.body.pattern['owner._r'] then verbose = true
                
            c.findModels(req.body.pattern, req.body.limits,
                (err,model) ->
                    reslist.push(model)
                () ->
                    flist = _.map reslist, (model) ->
                        (callback) ->
                            model.render req, callback,verbose
                        
                    async.parallel flist, (err,data) ->
                        res.end JSON.stringify(data)
                )
#        app.post helpers.makePath(path, name, 'findOne'), (req,res) => c.findOne req.body.pattern, (err,data) ->
#            res.end JSON.stringify(err: err, data: data)

        app.post helpers.makePath(path, name, 'findOne'), (req,res) =>
            c.findModel req.body.pattern, (err,model) ->
                if err or not model then return res.end JSON.stringify err: err, data: model
                model.render req, (err,data) -> res.end JSON.stringify err: err, data: data

        app.post helpers.makePath(path, name, 'call'), (req,res) -> c.fcall req.body.function, req.body.args or [], req.body.pattern, undefined, (err,data) ->
            res.end JSON.stringify err: err, data: data


