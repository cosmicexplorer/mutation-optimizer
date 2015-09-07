splitLength = (len, str) ->
  str[(ind)..(ind + len - 1)] for ind in [0..(str.length - 1)] by len
String.prototype.splitLength = (len) -> splitLength len, @
Array.prototype.splitLength = (len) -> splitLength len, @

sum = (arr) -> arr.reduce ((a, b) -> a + b), 0
Array.prototype.sum = -> sum @

countSubstr = (str, substr, weight) ->
  count = 0
  ind = str.indexOf substr
  while ind isnt -1
    count += weight or 1
    ind = str.indexOf substr
  count
String.prototype.countSubstr = (substr, weight) -> countSubstr @, substr, weight
Array.prototype.countSubstr = (substr, weight) -> countSubstr @, substr, weight

flatten = (arr, recursive) ->
  return arr if arr[0].constructor isnt Array
  res = arr.reduce (a, b) -> a.concat b
  if recursive and res[0].constructor is Array
    flatten res, yes
  else res
Array.prototype.flatten = (recursive) -> flatten @, recursive

ConvoluteKeysValues = (arr) ->
  arr = [arr] if arr.constructor isnt Array
  outObj = {}
  arr.forEach((obj) -> Object.keys(obj).forEach (k) ->
    outObj[val] = k for val in obj[k]
    null)
  outObj

module.exports =
  splitLength: splitLength
  countSubstr: countSubstr
  flatten: flatten
  ConvoluteKeysValues: ConvoluteKeysValues
  sum: sum
