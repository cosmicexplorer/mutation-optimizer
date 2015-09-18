fs = require 'fs'
stream = require 'stream'

async = require 'async'

PARALLEL_JOBS = 10

[begin = 0, end = -1] =  process.argv[2..]

{Count, AminoAcidSequence, DNASequence} = require '../lib/mutation-optimizer'

fs.readFile '../biobrick/out-file-seqs.json', (err, data) ->
  throw err if err
  seqs = JSON.parse data.toString()
  seqKeys = Object.keys seqs
  makeLogFromPart = (part) ->
    # take only the first from sequences (since we haven't found any part
    # which has more than one sequence, even though the xml admits the
    # possibility)
    seq = seqs[part][0]
    (new DNASequence seq).toAminoSeq().minimizeAllMutations(seq)
  # do this for the ones that pass amino acid checking, and also the ones that
  # pass dna checking
  aminoCheckStream = new stream.PassThrough
  aminoCheckStream.pipe fs.createWriteStream 'out-opt-counts-amino.json'
  dnaCheckStream = new stream.PassThrough
  dnaCheckStream.pipe fs.createWriteStream 'out-opt-counts-dna.json'

  aminoCheckStream.write '{\n'
  console.log "wow"
  aminoCheckParts = seqKeys.filter (part) ->
    try
      (new DNASequence seqs[part][0]).toAminoSeq().clean()
      return yes
    catch
      return no
  firstAminoPart = aminoCheckParts[0]
  aminoCheckStream.write "\"#{firstAminoPart}\":
  #{JSON.stringify makeLogFromPart firstAminoPart}\n"
  aminoCheckParts[1..][(begin)..(end)].forEach (part) ->
    console.log "amino start"
    try
      aminoCheckStream.write ",\"#{part}\":
      #{JSON.stringify makeLogFromPart part}\n"
      console.log "amino: #{part}"
    catch err
      console.log err.stack
      console.log [err.message, err.type]
  aminoCheckStream.end '}\n'

  dnaCheckStream.write '{\n'
  dnaCheckParts = seqKeys.filter (part) ->
    try
      (new DNASequence seqs[part][0]).clean()
      return yes
    catch
      return no
  firstDNAPart = dnaCheckParts[0]
  dnaCheckStream.write "\"#{firstDNAPart}\":
  #{JSON.stringify makeLogFromPart firstDNAPart}\n"
  dnaCheckParts[1..][(begin)..(end)].forEach (part) ->
    console.log "amino start"
    try
      dnaCheckStream.write ",\"#{part}\":
      #{JSON.stringify makeLogFromPart part}\n"
      console.log "dna: #{part}"
    catch err
      console.log err.stack
      console.log [err.message, err.type]
  dnaCheckStream.end '}\n'
