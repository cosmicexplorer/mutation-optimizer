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
  downloadPart = (part, cb, noComma) ->
    biobrick.getPartSeq part, (seq) ->
      line = "\"#{part}\": #{JSON.stringify seq}"
      line = "," + line unless noComma
      line += "\n"
      pct = (Math.round ++counter / arrLen * 100 * 100)
      pct = pct / 100
      console.log "about #{counter} / #{arrLen} (#{pct}%) downloaded"
      inStream.write line
      cb()
  queue = async.queue downloadPart
  inStream.pipe fs.createWriteStream 'out-file-seqs.json'
  inStream.write '{\n'
  queue.empty = ->
    inStream.write '}'
    console.log "DONE!"
  queue.concurrency = TASK_LIM
  downloadPart partNums[0], (-> queue.push partNums[1..]), yes
