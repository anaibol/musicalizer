# Camelize a string
# low_first_letter => lowFirstLetter
String::camelize = (lowercaseFirstLetter) ->
  string = @toLowerCase()
  
  str_path = string.split('/')

  for path, i in str_path
    str_arr = path.split('_')
    initX = if lowercaseFirstLetter && i+1 == str_path.length then 1 else 0
    for x in [initX...str_arr.length]
      console.log str_arr[x]
      str_arr[x] = str_arr[x].charAt(0).toUpperCase() + str_arr[x].substring(1)
    str_path[i] = str_arr.join('')
  str_path.join('::')