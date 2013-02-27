###
TableDnD plug-in for JQuery, allows you to drag and drop table rows
You can set up various options to control how the system will work
Copyright (c) Denis Howlett <denish@isocra.com>
Licensed like jQuery, see http://docs.jquery.com/License.

Configuration options:

onDragStyle
This is the style that is assigned to the row during drag. There are limitations to the styles that can be
associated with a row (such as you can't assign a border--well you can, but it won't be
displayed). (So instead consider using onDragClass.) The CSS style to apply is specified as
a map (as used in the jQuery css(...) function).
onDropStyle
This is the style that is assigned to the row when it is dropped. As for onDragStyle, there are limitations
to what you can do. Also this replaces the original style, so again consider using onDragClass which
is simply added and then removed on drop.
onDragClass
This class is added for the duration of the drag and then removed when the row is dropped. It is more
flexible than using onDragStyle since it can be inherited by the row cells and other content. The default
is class is tDnD_whileDrag. So to use the default, simply customise this CSS class in your
stylesheet.
onDrop
Pass a function that will be called when the row is dropped. The function takes 2 parameters: the table
and the row that was dropped. You can work out the new order of the rows by using
table.rows.
onDragStart
Pass a function that will be called when the user starts dragging. The function takes 2 parameters: the
table and the row which the user has started to drag.
onAllowDrop
Pass a function that will be called as a row is over another row. If the function returns true, allow
dropping on that row, otherwise not. The function takes 2 parameters: the dragged row and the row under
the cursor. It returns a boolean: true allows the drop, false doesn't allow it.
scrollAmount
This is the number of pixels to scroll if the user moves the mouse cursor to the top or bottom of the
window. The page should automatically scroll up or down as appropriate (tested in IE6, IE7, Safari, FF2,
FF3 beta
dragHandle
This is a jQuery mach string for one or more cells in each row that is draggable. If you
specify this, then you are responsible for setting cursor: move in the CSS and only these cells
will have the drag behaviour. If you do not specify a dragHandle, then you get the old behaviour where
the whole row is draggable.

Other ways to control behaviour:

Add class="nodrop" to any rows for which you don't want to allow dropping, and class="nodrag" to any rows
that you don't want to be draggable.

Inside the onDrop method you can also call $.tableDnD.serialize() this returns a string of the form
<tableID>[]=<rowID1>&<tableID>[]=<rowID2> so that you can send this back to the server. The table must have
an ID as must all the rows.

Other methods:

$("...").tableDnDUpdate()
Will update all the matching tables, that is it will reapply the mousedown method to the rows (or handle cells).
This is useful if you have updated the table rows using Ajax and you want to make the table draggable again.
The table maintains the original configuration (so you don't have to specify it again).

$("...").tableDnDSerialize()
Will serialize and return the serialized string as above, but for each of the matching tables--so it can be
called from anywhere and isn't dependent on the currentTable being set up correctly before calling

Known problems:
- Auto-scoll has some problems with IE7  (it scrolls even when it shouldn't), work-around: set scrollAmount to 0

Version 0.2: 2008-02-20 First public version
Version 0.3: 2008-02-07 Added onDragStart option
Made the scroll amount configurable (default is 5 as before)
Version 0.4: 2008-03-15 Changed the noDrag/noDrop attributes to nodrag/nodrop classes
Added onAllowDrop to control dropping
Fixed a bug which meant that you couldn't set the scroll amount in both directions
Added serialize method
Version 0.5: 2008-05-16 Changed so that if you specify a dragHandle class it doesn't make the whole row
draggable
Improved the serialize method to use a default (and settable) regular expression.
Added tableDnDupate() and tableDnDSerialize() to be called when you are outside the table
Version 0.6: 2011-12-02 Added support for touch devices
Version 0.7  2012-04-09 Now works with jQuery 1.7 and supports touch, tidied up tabs and spaces
###
(($) ->
  
  # Determine if this is a touch device
  hasTouch = "ontouchstart" of document.documentElement
  startEvent = (if hasTouch then "touchstart" else "mousedown")
  moveEvent = (if hasTouch then "touchmove" else "mousemove")
  endEvent = (if hasTouch then "touchend" else "mouseup")
  
  # If we're on a touch device, then wire up the events
  # see http://stackoverflow.com/a/8456194/1316086
  if hasTouch
    $.each "touchstart touchmove touchend".split(" "), (i, name) ->
      jQuery.event.fixHooks[name] = jQuery.event.mouseHooks

  jQuery.tableDnD =
    
    ###
    Keep hold of the current table being dragged
    ###
    currentTable: null
    
    ###
    Keep hold of the current drag object if any
    ###
    dragObject: null
    
    ###
    The current mouse offset
    ###
    mouseOffset: null
    
    ###
    Remember the old value of Y so that we don't do too much processing
    ###
    oldY: 0
    
    ###
    Actually build the structure
    ###
    build: (options) ->
      
      # Set up the defaults if any
      @each ->
        
        # This is bound to each matching table, set up the defaults and override with user options
        @tableDnDConfig = jQuery.extend(
          onDragStyle: null
          onDropStyle: null
          
          # Add in the default class for whileDragging
          onDragClass: "tDnD_whileDrag"
          onDrop: null
          onDragStart: null
          scrollAmount: 5
          serializeRegexp: /[^\-]*$/ # The regular expression to use to trim row IDs
          serializeParamName: null # If you want to specify another parameter name instead of the table ID
          dragHandle: null # If you give the name of a class here, then only Cells with this class will be draggable
        , options or {})
        
        # Now make the rows draggable
        jQuery.tableDnD.makeDraggable this

      
      # Don't break the chain
      this

    
    ###
    This function makes all the rows on the table draggable apart from those marked as "NoDrag"
    ###
    makeDraggable: (table) ->
      config = table.tableDnDConfig
      if config.dragHandle
        
        # We only need to add the event to the specified cells
        cells = jQuery(table.tableDnDConfig.dragHandle, table)
        cells.each ->
          
          # The cell is bound to "this"
          jQuery(this).bind startEvent, (ev) ->
            jQuery.tableDnD.initialiseDrag jQuery(this).parents("tr")[0], table, this, ev, config
            false


      else
        
        # For backwards compatibility, we add the event to the whole row
        rows = jQuery("tr", table) # get all the rows as a wrapped set
        rows.each ->
          
          # Iterate through each row, the row is bound to "this"
          row = jQuery(this)
          unless row.hasClass("nodrag")
            row.bind(startEvent, (ev) -> # Store the tableDnD object
              if ev.target.tagName is "TD"
                jQuery.tableDnD.initialiseDrag this, table, this, ev, config
                false
            ).css "cursor", "move"


    initialiseDrag: (dragObject, table, target, evnt, config) ->
      jQuery.tableDnD.dragObject = dragObject
      jQuery.tableDnD.currentTable = table
      jQuery.tableDnD.mouseOffset = jQuery.tableDnD.getMouseOffset(target, evnt)
      jQuery.tableDnD.originalOrder = jQuery.tableDnD.serialize()
      
      # Now we need to capture the mouse up and mouse move event
      # We can use bind so that we don't interfere with other event handlers
      jQuery(document).bind(moveEvent, jQuery.tableDnD.mousemove).bind endEvent, jQuery.tableDnD.mouseup
      
      # Call the onDragStart method if there is one
      config.onDragStart table, target  if config.onDragStart

    updateTables: ->
      @each ->
        
        # this is now bound to each matching table
        jQuery.tableDnD.makeDraggable this  if @tableDnDConfig


    
    ###
    Get the mouse coordinates from the event (allowing for browser differences)
    ###
    mouseCoords: (ev) ->
      if ev.pageX or ev.pageY
        return (
          x: ev.pageX
          y: ev.pageY
        )
      x: ev.clientX + document.body.scrollLeft - document.body.clientLeft
      y: ev.clientY + document.body.scrollTop - document.body.clientTop

    
    ###
    Given a target element and a mouse event, get the mouse offset from that element.
    To do this we need the element's position and the mouse position
    ###
    getMouseOffset: (target, ev) ->
      ev = ev or window.event
      docPos = @getPosition(target)
      mousePos = @mouseCoords(ev)
      x: mousePos.x - docPos.x
      y: mousePos.y - docPos.y

    
    ###
    Get the position of an element by going up the DOM tree and adding up all the offsets
    ###
    getPosition: (e) ->
      left = 0
      top = 0
      
      ###
      Safari fix -- thanks to Luis Chato for this!
      ###
      
      ###
      Safari 2 doesn't correctly grab the offsetTop of a table row
      this is detailed here:
      http://jacob.peargrove.com/blog/2006/technical/table-row-offsettop-bug-in-safari/
      the solution is likewise noted there, grab the offset of a table cell in the row - the firstChild.
      note that firefox will return a text node as a first child, so designing a more thorough
      solution may need to take that into account, for now this seems to work in firefox, safari, ie
      ###
      e = e.firstChild  if e.offsetHeight is 0 # a table cell
      while e.offsetParent
        left += e.offsetLeft
        top += e.offsetTop
        e = e.offsetParent
      left += e.offsetLeft
      top += e.offsetTop
      x: left
      y: top

    mousemove: (ev) ->
      return  unless jQuery.tableDnD.dragObject?
      
      # prevent touch device screen scrolling
      event.preventDefault()  if ev.type is "touchmove"
      dragObj = jQuery(jQuery.tableDnD.dragObject)
      config = jQuery.tableDnD.currentTable.tableDnDConfig
      mousePos = jQuery.tableDnD.mouseCoords(ev)
      y = mousePos.y - jQuery.tableDnD.mouseOffset.y
      
      #auto scroll the window
      yOffset = window.pageYOffset
      if document.all
        
        # Windows version
        #yOffset=document.body.scrollTop;
        if typeof document.compatMode isnt "undefined" and document.compatMode isnt "BackCompat"
          yOffset = document.documentElement.scrollTop
        else yOffset = document.body.scrollTop  unless typeof document.body is "undefined"
      if mousePos.y - yOffset < config.scrollAmount
        window.scrollBy 0, -config.scrollAmount
      else
        windowHeight = (if window.innerHeight then window.innerHeight else (if document.documentElement.clientHeight then document.documentElement.clientHeight else document.body.clientHeight))
        window.scrollBy 0, config.scrollAmount  if windowHeight - (mousePos.y - yOffset) < config.scrollAmount
      unless y is jQuery.tableDnD.oldY
        
        # work out if we're going up or down...
        movingDown = y > jQuery.tableDnD.oldY
        
        # update the old value
        jQuery.tableDnD.oldY = y
        
        # update the style to show we're dragging
        if config.onDragClass
          dragObj.addClass config.onDragClass
        else
          dragObj.css config.onDragStyle
        
        # If we're over a row then move the dragged row to there so that the user sees the
        # effect dynamically
        currentRow = jQuery.tableDnD.findDropTargetRow(dragObj, y)
        if currentRow
          if movingDown and jQuery.tableDnD.dragObject isnt currentRow and (jQuery.tableDnD.dragObject.parentNode is currentRow.parentNode)
            jQuery.tableDnD.dragObject.parentNode.insertBefore jQuery.tableDnD.dragObject, currentRow.nextSibling
          else jQuery.tableDnD.dragObject.parentNode.insertBefore jQuery.tableDnD.dragObject, currentRow  if not movingDown and jQuery.tableDnD.dragObject isnt currentRow and (jQuery.tableDnD.dragObject.parentNode is currentRow.parentNode)
      false

    
    ###
    We're only worried about the y position really, because we can only move rows up and down
    ###
    findDropTargetRow: (draggedRow, y) ->
      rows = jQuery.tableDnD.currentTable.rows
      i = 0

      while i < rows.length
        row = rows[i]
        rowY = @getPosition(row).y
        rowHeight = parseInt(row.offsetHeight) / 2
        if row.offsetHeight is 0
          rowY = @getPosition(row.firstChild).y
          rowHeight = parseInt(row.firstChild.offsetHeight) / 2
        
        # Because we always have to insert before, we need to offset the height a bit
        if (y > rowY - rowHeight) and (y < (rowY + rowHeight))
          
          # that's the row we're over
          # If it's the same as the current row, ignore it
          return null  if row is draggedRow
          config = jQuery.tableDnD.currentTable.tableDnDConfig
          if config.onAllowDrop
            if config.onAllowDrop(draggedRow, row)
              return row
            else
              return null
          else
            
            # If a row has nodrop class, then don't allow dropping (inspired by John Tarr and Famic)
            nodrop = jQuery(row).hasClass("nodrop")
            unless nodrop
              return row
            else
              return null
          return row
        i++
      null

    mouseup: (e) ->
      if jQuery.tableDnD.currentTable and jQuery.tableDnD.dragObject
        
        # Unbind the event handlers
        jQuery(document).unbind(moveEvent, jQuery.tableDnD.mousemove).unbind endEvent, jQuery.tableDnD.mouseup
        droppedRow = jQuery.tableDnD.dragObject
        config = jQuery.tableDnD.currentTable.tableDnDConfig
        
        # If we have a dragObject, then we need to release it,
        # The row will already have been moved to the right place so we just reset stuff
        if config.onDragClass
          jQuery(droppedRow).removeClass config.onDragClass
        else
          jQuery(droppedRow).css config.onDropStyle
        jQuery.tableDnD.dragObject = null
        newOrder = jQuery.tableDnD.serialize()
        
        # Call the onDrop method if there is one
        config.onDrop jQuery.tableDnD.currentTable, droppedRow  if config.onDrop and (jQuery.tableDnD.originalOrder isnt newOrder)
        jQuery.tableDnD.currentTable = null # let go of the table too

    jsonize: ->
      if jQuery.tableDnD.currentTable
        jQuery.tableDnD.jsonizeTable jQuery.tableDnD.currentTable
      else
        "Error: No Table id set, you need to set an id on your table and every row"

    jsonizeTable: (table) ->
      result = "{"
      tableId = table.id
      rows = table.rows
      result += "\"" + tableId + "\" : ["
      i = 0

      while i < rows.length
        rowId = rows[i].id
        rowId = rowId.match(table.tableDnDConfig.serializeRegexp)[0]  if rowId and rowId and table.tableDnDConfig and table.tableDnDConfig.serializeRegexp
        result += "\"" + rowId + "\""
        result += ","  if i < rows.length - 1
        i++
      result += "]}"
      result

    serialize: ->
      if jQuery.tableDnD.currentTable
        jQuery.tableDnD.serializeTable jQuery.tableDnD.currentTable
      else
        "Error: No Table id set, you need to set an id on your table and every row"

    serializeTable: (table) ->
      result = ""
      paramName = table.tableDnDConfig.serializeParamName or table.id
      rows = table.rows
      i = 0

      while i < rows.length
        result += "&"  if result.length > 0
        rowId = rows[i].id
        if rowId and table.tableDnDConfig and table.tableDnDConfig.serializeRegexp
          rowId = rowId.match(table.tableDnDConfig.serializeRegexp)[0]
          result += tableId + "[]=" + rowId
        i++
      result

    serializeTables: ->
      result = ""
      @each ->
        
        # this is now bound to each matching table
        result += jQuery.tableDnD.serializeTable(this)

      result

  jQuery.fn.extend
    tableDnD: jQuery.tableDnD.build
    tableDnDUpdate: jQuery.tableDnD.updateTables
    tableDnDSerialize: jQuery.tableDnD.serializeTables

) jQuery