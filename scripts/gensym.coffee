gensym = ->
  id = Math.random()
  while document.getElementById id
    id = Math.random()
  id

module.exports = gensym
