fs = require 'fs'

getSums = (counts) ->
  Object.keys(counts).map((k) -> counts[k]).reduce (a, b) ->
    a[k] += v for k, v of b
    a

getCSVString = (counts) ->
  firstLine = Object.keys(counts[Object.keys(counts)[0]]).join ','
  lines = for k, v of counts
    vals = Object.keys(v).map (count) -> v[count]
    "#{k},#{vals.join ','}"
  firstLine + '\n' + lines.join '\n'

fs.readFile 'out-counts-amino.json', (err, data) ->
  throw err if err
  AminoCounts = JSON.parse data.toString()
  sums = JSON.parse JSON.stringify getSums AminoCounts
  sums.howManyParts = Object.keys(AminoCounts).length
  fs.writeFile 'total-counts-amino.json', (JSON.stringify sums), (err) ->
    throw err if err
  fs.writeFile 'amino-counts.csv', (getCSVString AminoCounts), (err) ->
    throw err if err

fs.readFile 'out-counts-dna.json', (err, data) ->
  throw err if err
  DNACounts = JSON.parse data.toString()
  sums = JSON.parse JSON.stringify getSums DNACounts
  sums.howManyParts = Object.keys(DNACounts).length
  fs.writeFile 'total-counts-dna.json', (JSON.stringify sums), (err) ->
    throw err if err
  fs.writeFile 'dna-counts.csv', (getCSVString DNACounts), (err) ->
    throw err if err
