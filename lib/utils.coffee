_ = require 'lodash'

splitLength = (len, str) ->
  str[(ind)..(ind + len - 1)] for ind in [0..(str.length - 1)] by len
String.prototype.splitLength = (len) -> splitLength len, @
Array.prototype.splitLength = (len) -> splitLength len, @

sum = (arr) -> arr.reduce ((a, b) -> a + b), 0
Array.prototype.sum = -> sum @

countSubstr = (str, substr) ->
  count = 0
  ind = str.indexOf substr
  while ind isnt -1
    ++count
    ind = str.indexOf substr, ind + 1
  count
String.prototype.countSubstr = (substr) -> countSubstr @, substr
Array.prototype.countSubstr = (substr) -> countSubstr @, substr

ConvoluteKeysValues = (arr) ->
  arr = [arr] if arr.constructor isnt Array
  outObj = {}
  arr.forEach((obj) -> Object.keys(obj).forEach (k) ->
    outObj[val] = k for val in obj[k]
    null)
  outObj

# given a singly-nested array of the form [[...],[...],[...]], return all
# combinations of elements within first array, then elements within second
# array, then third. e.g.: [[1,2,3],[5,3]] ->
#   [[1,5],[1,3],[2,5],[2,3],[3,5],[3,3]]
# DO NOT USE THIS FOR LISTS OF UNBOUNDED SIZE, RECURSION WILL KILL YOU
getAllCombinations = (arrOfArrs) ->
  switch arrOfArrs.length
    when 0 then []
    when 1 then arrOfArrs[0]
    else _.flatten arrOfArrs[0].map (el) ->
      getAllCombinations(arrOfArrs[1..]).map (arr) -> [el].concat arr
Array.prototype.getAllCombinations = -> getAllCombinations @

module.exports = {
  splitLength
  sum
  countSubstr
  ConvoluteKeysValues
  getAllCombinations
}
