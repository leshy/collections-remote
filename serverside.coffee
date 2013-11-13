helpers = require 'helpers'
Backbone = require 'backbone4000'    

# exposes a collection via HTTP (express)
CollectionExposerHttp = exports.CollectionExposerHttp = Backbone.Model.extend4000
    initialize: ->       
        path = @get 'path'
        app = @get 'app'
        c = @get 'collection'
        name = c.get 'name'
        
        callbackToRes = (res) -> (err,data) ->
            console.log 'res',err,data
            res.end JSON.stringify err: err, data: data

        app.post helpers.makePath(path, name, 'create'), (req,res) -> c.create req.body.data, callbackToRes(res)
        app.post helpers.makePath(path, name, 'remove'), (req,res) => c.remove req.body.pattern, callbackToRes(res)
        app.post helpers.makePath(path, name, 'update'), (req,res) => c.update req.body.pattern, req.body.data, callbackToRes(res)
        
        app.post helpers.makePath(path, name, 'find'), (req,res) => c.findModels req.body.pattern, req.body.limits, (model) -> 
            if model then res.write JSON.stringify(model.attributes) else res.end()

        app.post helpers.makePath(path, name, 'findOne'), (req,res) => c.findModel req.body.pattern, (err,model) ->
            res.end JSON.stringify(err: err, data: model.attributes)

        app.post helpers.makePath(path, name, 'call'), (req,res) -> c.fcall req.body.function, req.body.args or [], req.body.pattern, undefined, (err,data) ->
            res.end JSON.stringify err: err, data: data

