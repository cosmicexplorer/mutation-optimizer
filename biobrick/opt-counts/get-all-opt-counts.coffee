_ = require 'lodash'
fs = require 'fs'

f1 = JSON.parse fs.readFileSync './out-0-120-opt-counts-dna.json'
f2 = JSON.parse fs.readFileSync './out-121-240-opt-counts-dna.json'
f3 = JSON.parse fs.readFileSync './out-241-480-opt-counts-dna.json'
f4 = JSON.parse fs.readFileSync './out-481-960-opt-counts-dna.json'
f5 = JSON.parse fs.readFileSync './out-0-120-opt-counts-amino.json'
f6 = JSON.parse fs.readFileSync './out-121-240-opt-counts-amino.json'
f7 = JSON.parse fs.readFileSync './out-241-480-opt-counts-amino.json'
f8 = JSON.parse fs.readFileSync './out-481-960-opt-counts-amino.json'

allCounts = {}
[f1, f2, f3, f4, f5, f6, f7, f8].forEach (obj) ->
  allCounts[k] = v for k, v of obj

nonSpecificOptimizations = ['global', 'original', 'mutability_score']

keysOfFirstEl = (Object.keys allCounts[(Object.keys allCounts)[0]])
keys = _.without.apply null, [keysOfFirstEl].concat nonSpecificOptimizations
console.error {keys}

opt = {}
orig = {}
for key, v of allCounts
  for k in keys
    opt_k = v[k][k]
    if opt[k] then opt[k] += opt_k
    else opt[k] = opt_k
    orig_k = v.original[k]
    if orig[k] then orig[k] += orig_k
    else orig[k] = orig_k

console.error {opt, orig}

percentRound = (num) -> Math.round(num * 10000) / 100
optPcnt = {}
optPcnt[k] = percentRound((orig[k] - opt[k]) / orig[k]) for k in keys
console.error {optPcnt}

console.error "#{k}: #{v}% reduction" for k, v of optPcnt

# these were incorrectly calculated during the process of sieving through the
# registry, and unfortunately have to be discounted
testFailures = ['hairpinSites', 'homologyRepeatCount']

str = fs.createWriteStream 'reductions.csv'
str.write "name,reduction\n"
(str.write "#{k},#{v}\n" unless k in testFailures) for k, v of optPcnt
str.end()
