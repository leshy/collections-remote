helpers = require 'helpers'
Backbone = require 'backbone4000'    
_ = require 'underscore'
async = require 'async'

# exposes a collection via HTTP (express)
CollectionExposerHttpRaw = exports.CollectionExposerHttpRaw = Backbone.Model.extend4000
    initialize: ->       
        path = @get 'path'
        app = @get 'app'
        c = @get 'collection'
        name = c.get 'name'

        callbackToRes = (res) -> (err,data) -> res.end JSON.stringify err: err, data: data

        app.post helpers.makePath(path, name, 'create'), (req,res) -> c.create req.body.data, callbackToRes(res)
        app.post helpers.makePath(path, name, 'remove'), (req,res) => c.remove req.body.pattern, callbackToRes(res)
        app.post helpers.makePath(path, name, 'update'), (req,res) => c.update req.body.pattern, req.body.data, callbackToRes(res)
        
        app.post helpers.makePath(path, name, 'find'), (req,res) =>
            reslist = []
            c.find req.body.pattern, req.body.limits, (err,data) ->
                if data
                    reslist.push(data)
                else 
                    res.end JSON.stringify(reslist)

        app.post helpers.makePath(path, name, 'findOne'), (req,res) => c.findOne req.body.pattern, (err,data) ->
            res.end JSON.stringify(err: err, data: data)

        app.post helpers.makePath(path, name, 'call'), (req,res) -> c.fcall req.body.function, req.body.args or [], req.body.pattern, undefined, (err,data) ->
            res.end JSON.stringify err: err, data: data


CollectionExposerHttpFancy = exports.CollectionExposerHttpFancy = Backbone.Model.extend4000
    initialize: ->       
        path = @get 'path'
        app = @get 'app'
        c = @get 'collection'
        name = c.get 'name'

        callbackToRes = (res) -> (err,data) -> res.end JSON.stringify err: err, data: data

        app.post helpers.makePath(path, name, 'create'), (req,res) -> c.create req.body.data, callbackToRes(res)
        app.post helpers.makePath(path, name, 'remove'), (req,res) => c.remove req.body.pattern, callbackToRes(res)
        app.post helpers.makePath(path, name, 'update'), (req,res) => c.update req.body.pattern, req.body.data, callbackToRes(res)
        
        app.post helpers.makePath(path, name, 'find'), (req,res) =>
            reslist = []
            c.findModels req.body.pattern, req.body.limits, (err,model) ->
                if model
                    reslist.push(model)
                else
                    flist = _.map reslist, (model) ->
                        (callback) -> model.render req, callback
                        
                    async.parallel flist, (err,data) ->
                        res.end JSON.stringify(data)

        app.post helpers.makePath(path, name, 'findOne'), (req,res) => c.findModel req.body.pattern, (err,model) ->
            model.render req, (err,data) -> res.end JSON.stringify err: err, data: data

        app.post helpers.makePath(path, name, 'call'), (req,res) -> c.fcall req.body.function, req.body.args or [], req.body.pattern, undefined, (err,data) ->
            res.end JSON.stringify err: err, data: data

