module.exports = ->
  fs = require('fs')
  
  dashToCamel = (str) ->
    str.replace /(\-[a-z])/g, ($1) ->
      $1.toUpperCase().replace '-', ''

  fs.readdir controllersDir, (err, files) ->
    files.forEach (file) ->

      if /.coffee$/.test(file)
        # add the standard route

        app.get '/' + file.replace(/(^index)?\.coffee$/, '') + '/:action?/:id?', (request, response) ->
          mdl = require(controllersDir + file)
          controller = new mdl.controller(request, response)
          
          if controller.before_filter()
            # build action parameter
            unless request.params.action
              request.params.action = 'indexAction'
            else
              request.params.action = dashToCamel(request.params.action)
              request.params.action += 'Action'
            
            # try to call the action
            if typeof controller[request.params.action] is 'function'
              controller[request.params.action]()
            else
              response.send request.params.action + ' is not a controller action'

            controller.after_filter()
          #delete controller

BaseController = (request, response) ->
  @request = request
  @response = response
  @render = (template, options) ->
    @response.render template, options

  @send = (content) ->
    @response.send content

  @extend = (child) ->
    for p of child
      this[p] = child[p]
    this

  @before_filter = ->
    true

  @after_filter = ->


###

      switch key
        when 'show'
          method = 'get'
          path = '/' + name + '/:' + name + '_id'
        when 'list'
          method = 'get'
          path = '/' + name + 's'
        when 'edit'
          method = 'get'
          path = '/' + name + '/:' + name + '_id/edit'
        when 'update'
          method = 'put'
          path = '/' + name + '/:' + name + '_id'
        when 'create'
          method = 'post'
          path = '/' + name
        when 'index'
          method = 'get'
          path = '/'
        else
          throw new Error('unrecognized route: ' + name + '.' + key)
