var ConvoluteKeysValues, _, countSubstr, getAllCombinations, indicesOfOccurrences, splitLength, sum;

_ = require('lodash');

splitLength = function(len, str) {
  var i, ind, ref, ref1, results;
  results = [];
  for (ind = i = 0, ref = str.length - 1, ref1 = len; ref1 > 0 ? i <= ref : i >= ref; ind = i += ref1) {
    results.push(str.slice(ind, +(ind + len - 1) + 1 || 9e9));
  }
  return results;
};

String.prototype.splitLength = function(len) {
  return splitLength(len, this);
};

Array.prototype.splitLength = function(len) {
  return splitLength(len, this);
};

sum = function(arr) {
  return arr.reduce((function(a, b) {
    return a + b;
  }), 0);
};

Array.prototype.sum = function() {
  return sum(this);
};

indicesOfOccurrences = function(str, substr, incrementBySubstr) {
  var amountToIncrement, ind, prevInd, results;
  amountToIncrement = incrementBySubstr ? substr.length : 1;
  ind = str.indexOf(substr);
  results = [];
  while (ind !== -1) {
    prevInd = ind;
    ind = str.indexOf(substr, ind + amountToIncrement);
    results.push(prevInd);
  }
  return results;
};

String.prototype.indicesOfOccurrences = function(substr, inc) {
  return indicesOfOccurrences(this, substr, inc);
};

Array.prototype.indicesOfOccurrences = function(substr, inc) {
  return indicesOfOccurrences(this, substr, inc);
};

countSubstr = function(str, substr, incrementBySubstr) {
  var amountToIncrement, count, ind;
  amountToIncrement = incrementBySubstr ? substr.length : 1;
  count = 0;
  ind = str.indexOf(substr);
  while (ind !== -1) {
    ++count;
    ind = str.indexOf(substr, ind + amountToIncrement);
  }
  return count;
};

String.prototype.countSubstr = function(substr, inc) {
  return countSubstr(this, substr, inc);
};

Array.prototype.countSubstr = function(substr, inc) {
  return countSubstr(this, substr, inc);
};

ConvoluteKeysValues = function(arr) {
  var outObj;
  if (arr.constructor !== Array) {
    arr = [arr];
  }
  outObj = {};
  arr.forEach(function(obj) {
    return Object.keys(obj).forEach(function(k) {
      var i, len1, ref, val;
      ref = obj[k];
      for (i = 0, len1 = ref.length; i < len1; i++) {
        val = ref[i];
        outObj[val] = k;
      }
      return null;
    });
  });
  return outObj;
};

getAllCombinations = function(arrOfArrs) {
  switch (arrOfArrs.length) {
    case 0:
      return [];
    case 1:
      return arrOfArrs[0];
    default:
      return _.flatten(arrOfArrs[0].map(function(el) {
        return getAllCombinations(arrOfArrs.slice(1)).map(function(arr) {
          return [el].concat(arr);
        });
      }));
  }
};

Array.prototype.getAllCombinations = function() {
  return getAllCombinations(this);
};

module.exports = {
  splitLength: splitLength,
  sum: sum,
  countSubstr: countSubstr,
  ConvoluteKeysValues: ConvoluteKeysValues,
  getAllCombinations: getAllCombinations
};
