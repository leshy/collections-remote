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
RemoteCollectionHttp = exports.RemoteCollectionHttp = Backbone.Model.extend4000 collections.ModelMixin, collections.ReferenceMixin,

    create: (data,callback) ->
        post helpers.makePath(@get('path'), 'create'), { data: data }, (err,res) -> if not err then callback res.err, res.data else callback err, res
        undefined

    remove: (pattern,callback) ->
        post helpers.makePath(@get('path'), 'remove'), { pattern: pattern }, (err,res) -> if not err then callback res.err, res.data else callback err, res
        undefined
            
    find: (pattern={},limits={},callback) ->
        post helpers.makePath(@get('path'), 'find'), { pattern: pattern, limits: limits }, (err,res) ->
            if err then callback err, undefined
            _.map res, (element) -> callback undefined, element
            
        undefined

    findOne: (pattern={},callback) ->
        post helpers.makePath(@get('path'), 'findOne'), { pattern: pattern }, (err,res) -> if not err then callback res.err, res.data else callback err, res
        undefined
        
    subscribeModel: -> true


###                
    _create: (entry,callback) -> core.msgCallback @send( collection: @get('name'), create: entry ), callback
    
    _remove: (pattern,callback) -> core.msgCallback @send( collection: @get('name'), remove: pattern, raw: true ), callback
    
    _update: (pattern,data,callback) -> core.msgCallback @send( collection: @get('name'), update: pattern, data: data, raw: true ), callback
    

    _findOne: (pattern,callback) ->
        reply = @send( collection: @get('name'), findOne: pattern )
        reply.read (msg) -> if msg then callback(undefined,msg.data) else callback("not found")

    _fcall: (name, args, pattern, callback) ->
        reply = @send( collection: @get('name'), call: name, args: args, data: pattern )
        reply.read (msg) -> if msg then helpers.cbc callback, msg.err, msg.data;

###

