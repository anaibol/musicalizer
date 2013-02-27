(($) ->
  toggleLabel = ->
    input = $(this)
    unless input.parent().hasClass('placeholder')
      label = $('<label>').addClass('placeholder')
      input.wrap label
      span = $('<span>')
      span.text input.attr('placeholder')
      input.removeAttr 'placeholder'
      span.insertBefore input
    setTimeout (->
      def = input.attr('title')
      if not input.val() or (input.val() is def)
        input.prev('span').css 'visibility', ''
        if def
          dummy = $('<label></label>').text(def).css('visibility', 'hidden').appendTo('body')
          input.prev('span').css 'margin-left', dummy.width() + 3 + 'px'
          dummy.remove()
      else
        input.prev('span').css 'visibility', 'hidden'
    ), 0
    
  resetField = ->
    def = $(this).attr('title')
    if not $(this).val() or ($(this).val() is def)
      $(this).val def
      $(this).prev('span').css 'visibility', ''

  fields = $('input, textarea')
  fields.live 'keydown', toggleLabel
  fields.live 'paste', toggleLabel
  fields.live 'focusin', ->
    #$(this).prev('span').css 'color', '#ccc'    
    $(this).prev('span').animate
      color: "#ccc"
      #opacity:'0.5'      
    , 500

  fields.live "focusout", ->
    #$(this).prev("span").css "color", "#999"        
    $(this).prev("span").animate
      color: "#999"
      #opacity:'1'
    , 500

  $ ->
    $('input[placeholder], textarea[placeholder]').each ->
      toggleLabel.call this


) jQuery