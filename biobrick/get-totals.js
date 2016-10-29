var fs, getCSVString, getSums;

fs = require('fs');

getSums = function(counts) {
  return Object.keys(counts).map(function(k) {
    return counts[k];
  }).reduce(function(a, b) {
    var k, v;
    for (k in b) {
      v = b[k];
      a[k] += v;
    }
    return a;
  });
};

getCSVString = function(counts) {
  var firstLine, k, lines, v, vals;
  firstLine = Object.keys(counts[Object.keys(counts)[0]]).join(',');
  lines = (function() {
    var results;
    results = [];
    for (k in counts) {
      v = counts[k];
      vals = Object.keys(v).map(function(count) {
        return v[count];
      });
      results.push(k + "," + (vals.join(',')));
    }
    return results;
  })();
  return firstLine + '\n' + lines.join('\n');
};

fs.readFile('out-counts-amino.json', function(err, data) {
  var AminoCounts, sums;
  if (err) {
    throw err;
  }
  AminoCounts = JSON.parse(data.toString());
  sums = JSON.parse(JSON.stringify(getSums(AminoCounts)));
  sums.howManyParts = Object.keys(AminoCounts).length;
  fs.writeFile('total-counts-amino.json', JSON.stringify(sums), function(err) {
    if (err) {
      throw err;
    }
  });
  return fs.writeFile('amino-counts.csv', getCSVString(AminoCounts), function(err) {
    if (err) {
      throw err;
    }
  });
});

fs.readFile('out-counts-dna.json', function(err, data) {
  var DNACounts, sums;
  if (err) {
    throw err;
  }
  DNACounts = JSON.parse(data.toString());
  sums = JSON.parse(JSON.stringify(getSums(DNACounts)));
  sums.howManyParts = Object.keys(DNACounts).length;
  fs.writeFile('total-counts-dna.json', JSON.stringify(sums), function(err) {
    if (err) {
      throw err;
    }
  });
  return fs.writeFile('dna-counts.csv', getCSVString(DNACounts), function(err) {
    if (err) {
      throw err;
    }
  });
});
