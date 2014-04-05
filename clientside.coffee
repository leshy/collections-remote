Backbone = require 'backbone4000'
collections = require 'collections'
helpers = require 'helpers'

post = (url,data,callback) ->
    # shouldn't jquery be doing this by itself already?
    #data = helpers.dictmap data, (value,key) -> if value.constructor is Object then JSON.stringify(value) else value
    $.ajax url,
        type: "POST",
        contentType:"application/json; charset=utf-8",
        dataType:"json",
        data: JSON.stringify(data),
        success: (data) -> callback undefined, data
        error: (xhr,status,err) -> callback status

# has the same interface as local collections but it transparently talks to the remote collectionExposer via http
RemoteCollectionHttp = Backbone.Model.extend4000 collections.ModelMixin, collections.ReferenceMixin,

    create: (data,callback) ->
        post helpers.makePath(@get('path') + @get('name'), 'create'), { data: data }, (err,res) -> if not err then callback res.err, res.data else callback err, res
        undefined

    remove: (pattern,callback) ->
        post helpers.makePath(@get('path') + @get('name'), 'remove'), { pattern: pattern }, (err,res) -> if not err then callback res.err, res.data else callback err, res
        undefined
            
    find: (pattern={},limits={},callback,callbackDone) ->
        post helpers.makePath(@get('path') + @get('name'), 'find'), { pattern: pattern, limits: limits }, (err,res) ->
            if err then callback err, undefined
            _.map res, (element) -> callback undefined, element
            helpers.cbc callbackDone
            
        undefined

    findOne: (pattern={},callback) ->
        post helpers.makePath(@get('path') + @get('name'), 'findOne'), { pattern: pattern }, (err,res) -> if not err then callback res.err, res.data else callback err, res
        undefined

    update: (pattern,data,callback) ->
        post helpers.makePath(@get('path') + @get('name'), 'update'), { pattern: pattern, data: data }, (err,res) -> if not err then callback res.err, res.data else callback err, res
        undefined
                        

RemoteCollectionHttp = exports.RemoteCollectionHttp = RemoteCollectionHttp.extend4000 collections.RequestIdMixin, collections.CachingMixin