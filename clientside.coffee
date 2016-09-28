Backbone = require 'backbone4000'
collections = require 'collections'
helpers = require 'helpers'


if not global.window
    req = 'request'
    request = require req
    post = (url,data,callback) ->
        options =  {
            url: url
            method: "POST"
            json: data
        }
        
        request options, (err,req,data) -> callback err,data                
else

    post = (url,data,callback) ->
        xhr = new XMLHttpRequest
        #console.log "POST URL", url, JSON.stringify(data.pattern)
        
        xhr.open "POST", url        
        xhr.setRequestHeader "Content-Type", "application/json;charset=UTF-8"

        gotData = -> callback undefined, JSON.parse(xhr.responseText)
        
        gotErr = -> callback true
        
        gotProgress = (oEvent) ->
          if (oEvent.lengthComputable)
            percentComplete = oEvent.loaded / oEvent.total;
            
        xhr.addEventListener "load", gotData
        xhr.addEventListener "error", gotErr
        #xhr.addEventListener "progress", gotProgress
        
        xhr.send JSON.stringify(data)

# has the same interface as local collections but it transparently talks to the remote collectionExposer via http
RemoteCollectionHttp = exports.RemoteCollectionHttp = Backbone.Model.extend4000 

    getpath: (query) ->
        path = helpers.makePath(@get('path') + @get('name'), query)
        if not host = @get('host') then path else host + path
        
    create: (data,callback) ->
        post @getpath('create'), { data: data }, (err,res) ->
            if not err then callback res.err, res.data else callback err, res
        undefined

    remove: (pattern,callback) ->
        post @getpath('remove'), { pattern: pattern }, (err,res) -> if not err then callback res.err, res.data else callback err, res
        undefined
            
    find: (pattern={},limits={},callback,callbackDone) ->
        post @getpath('find'), { pattern: pattern, limits: limits }, (err,res) ->
            if err then callback err, undefined
            _.map res, (element) -> callback undefined, element
            helpers.cbc callbackDone, err, true
        undefined

    findOne: (pattern={},callback) ->
        post @getpath('findOne'), { pattern: pattern }, (err,res) -> if not err then callback res.err, res.data else callback err, res
        undefined

    update: (pattern,data,callback) ->
        post @getpath('update'), { pattern: pattern, data: data }, (err,res) -> if not err then callback res.err, res.data else callback err, res
        undefined


RemoteCollectionHttp = exports.RemoteCollectionHttp = RemoteCollectionHttp.extend4000 collections.ReferenceMixin, collections.ModelMixin, collections.RequestIdMixin, collections.CachingMixin # these mixings should hook find
