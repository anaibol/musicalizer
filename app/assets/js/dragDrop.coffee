(($) ->
  cancelDestElement = (options) ->
    if $destElement?
      $destElement.removeClass options.dropClass  if options.dropClass
      $destElement = null

    $activeElement.removeClass options.canDropClass  if options.canDropClass  if $activeElement?

  defaultOptions =
    makeClone: true
    sourceClass: null
    sourceHide: true
    dragClass: 'dragging'
    canDropClass: null
    dropClass: null
    isActive: true
    container: null
    canDrag: ($src, event) ->
      $src

    canDrop: ($dst) ->
      $dst.hasClass('drop') or $dst.parents('.drop').size() > 0

    didDrop: ($src, $dst) ->
      $src.appendTo $dst
  
  $sourceElement = null
  $activeElement = null
  $destElement = null
  dragOffsetX = undefined
  dragOffsetY = undefined
  limits = undefined

  # Public methods
  methods =
    init: (options) ->
      options = $.extend({}, defaultOptions, options)
      @data 'options', options
      @bind 'mousedown.dragdrop touchstart.dragdrop', methods.onStart
      this

    destroy: ->
      @unbind 'mousedown.dragdrop touchstart.dragdrop'
      this

    on: ->
      @data('options').isActive = true

    off: ->
      @data('options').isActive = false

    onStart: (event) ->
      $me = $(this)
      options = $me.data('options')

      return  unless options.isActive

      $element = options.canDrag($me, event)

      if $element
        $sourceElement = $element
        offset = $sourceElement.offset()
        width = $sourceElement.width()
        height = $sourceElement.height()

        if event.type is 'touchstart'
          dragOffsetX = event.originalEvent.touches[0].clientX - offset.left
          #dragOffsetY = event.originalEvent.touches[0].clientY - offset.top
        else
          dragOffsetX = event.pageX - offset.left
          #dragOffsetY = event.pageY - offset.top

        $(window).bind('mousemove.dragdrop touchmove.dragdrop',
          source: $me
        , methods.onMove)

        .bind('mouseup.dragdrop touchend.dragdrop',
          source: $me
        , methods.onEnd)

        event.stopPropagation()
        false

    onMove: (event) ->
      $me = event.data.source
      options = $me.data('options')

      if event.type is 'touchmove'
        posX = event.originalEvent.touches[0].clientX
        posY = event.originalEvent.touches[0].clientY
      else
        posX = event.pageX
        posY = event.pageY

      if not $activeElement
        $element = options.canDrag($me, event)
        if $element
          $sourceElement = $element
          offset = $sourceElement.offset()
          width = $sourceElement.width()
          height = $sourceElement.height()

        if options.makeClone
          $activeElement = $sourceElement.clone(false).add()
          console.log $activeElement = ''
          
          # Elements that are cloned and dragged around are added to the parent in order
          # to get any cascading styles applied.
          $activeElement.appendTo $element.parent()
          if options.sourceClass
            $sourceElement.addClass options.sourceClass
          else $sourceElement.css 'visibility', 'hidden'  if options.sourceHide
        else
          $activeElement = $sourceElement
        $activeElement.css
          position: 'absolute'
          left: offset.left
          #top: offset.top
          width: width
          height: height

        $activeElement.addClass options.dragClass  if options.dragClass
        $c = options.container
        if $c
          offset = $c.offset()
          limits =
            minX: offset.left
            #minY: offset.top
            maxX: offset.left + $c.outerWidth() - $element.outerWidth()
            #maxY: offset.top + $c.outerHeight() - $element.outerHeight()

      else
        $activeElement.css 'display', 'none'
        destElement = document.elementFromPoint(posX - document.documentElement.scrollLeft - document.body.scrollLeft, posY - document.documentElement.scrollTop - document.body.scrollTop)
        $activeElement.css 'display', ''

        posX -= dragOffsetX
        posY -= dragOffsetY

        if limits
          posX = Math.min(Math.max(posX, limits.minX), limits.maxX)
          posY = Math.min(Math.max(posY, limits.minY), limits.maxY)
        $activeElement.css
          left: posX
          #top: posY

        if destElement
          if not $destElement? or $destElement.get(0) isnt destElement
            $possibleDestElement = $(destElement)
            if options.canDrop($possibleDestElement)
              if options.dropClass
                $destElement.removeClass options.dropClass  if $destElement?
                $possibleDestElement.addClass options.dropClass
              $activeElement.addClass options.canDropClass  if options.canDropClass
              $destElement = $possibleDestElement
            else cancelDestElement options  if $destElement?
        else cancelDestElement options  if $destElement?
        event.stopPropagation()
      false

    onEnd: (event) ->
      if not $activeElement
        $(window).unbind('mousemove.dragdrop touchmove.dragdrop')
        .unbind('mouseup.dragdrop touchend.dragdrop')

      else
        $me = event.data.source
        options = $me.data('options')
        options.didDrop $sourceElement, $destElement  if $destElement
        cancelDestElement options
        if options.makeClone
          $activeElement.remove()
          if options.sourceClass
            $sourceElement.removeClass options.sourceClass
          else $sourceElement.css 'visibility', 'visible'  if options.sourceHide
        else
          $activeElement.css 'position', 'static'
          $activeElement.css 'width', ''
          $activeElement.css 'height', ''
          $activeElement.removeClass options.dragClass  if options.dragClass
        $(window).unbind 'mousemove.dragdrop touchmove.dragdrop'
        $(window).unbind 'mouseup.dragdrop touchend.dragdrop'
        $sourceElement = $activeElement = limits = null

  $.fn.dragdrop = (method) ->
    if methods[method]
      methods[method].apply this, Array::slice.call(arguments, 1)
    else if typeof method is 'object' or not method
      methods.init.apply this, arguments
    else
      $.error 'Method ' + method + ' does not exist on jQuery.dragdrop'
) jQuery