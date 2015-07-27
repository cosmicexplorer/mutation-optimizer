splitLength = (len, str) ->
  str[(ind)..(ind + len - 1)] for ind in [0..(str.length - 1)] by len
String.prototype.splitLength = (len) -> splitLength len, @

flatten = (arr, recursive) ->
  return arr if arr[0].constructor isnt Array
  res = arr.reduce (a, b) -> a.concat b
  if recursive and res[0].constructor is Array
    flatten res, yes
  else res
Array.prototype.flatten = (recursive) -> flatten @, recursive

ConvoluteKeysValues = (arr) ->
  arr = [arr] if arr.constructor isnt Array
  arr.map((obj) -> Object.keys(obj).map((k) ->
    for val in obj[k]
      newObj = {}
      newObj[val] = k
      newObj)).flatten yes

module.exports =
  splitLength: splitLength
  flatten: flatten
  ConvoluteKeysValues: ConvoluteKeysValues
