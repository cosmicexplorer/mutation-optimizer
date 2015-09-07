fs = require 'fs'
stream = require 'stream'

async = require 'async'

biobrick = require './biobrick'

TASK_LIM = 50

counter = 0

fs.readFile 'out-file-cleaned', (err, data) ->
  throw err if err
  partNums = JSON.parse data.toString()
  arrLen = partNums.length
  inStream = new stream.PassThrough
  queue = async.queue (part, cb) ->
    biobrick.getPartSeq part, (seq) ->
      line = "\"#{part}\": #{JSON.stringify seq}\n"
      pct = (Math.round ++counter / arrLen * 100 * 100)
      pct = pct / 100
      console.log "about #{counter} / #{arrLen} (#{pct}%) downloaded"
      inStream.write line
      cb()
  inStream.pipe fs.createWriteStream 'out-file-seqs.json'
  inStream.write '{\n'
  queue.empty = ->
    inStream.write '}'
    console.log "DONE!"
  queue.concurrency = TASK_LIM
  queue.push partNums
