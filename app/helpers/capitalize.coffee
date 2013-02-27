# Capitalize a string
# string => String
String::capitalize = ->
    this.replace /(?:^|\s)\S/g, (a) -> a.toUpperCase()