_ = require 'lodash'
fs = require 'fs'
rwlock = require 'rwlock'

biobrick = require './biobrick'
mutOpt = require '../lib/mutation-optimizer'

lock = new rwlock

# run this through the seq checker!!!
fs.readFile 'out-file-cleaned', (err, data) ->
  throw err if err
  _.uniq(JSON.parse(data.toString())).map (bb) ->
     biobrick.getPartSeq bb, (seq) ->
       counts = mutOpt.counts seq
       line = JSON.stringify {"#{bb}": counts}
       lock.writeLock (release) ->
         fs.appendFile 'out-file-seq-data.yaml', line, (err) ->
           throw err if err
           release()
