var gensym;

gensym = function() {
  var id;
  id = Math.random();
  while (document.getElementById(id)) {
    id = Math.random();
  }
  return id;
};

module.exports = gensym;
