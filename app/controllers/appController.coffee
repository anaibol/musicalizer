ExampleController = (request, result) ->
  BaseController.call this, request, result
  @y = 0
  @indexAction = ->
    @render "index",
      locals:
        title: "Express"


  @testAction = ->
    @y += 1
    @send @y + ""

exports.controller = ExampleController