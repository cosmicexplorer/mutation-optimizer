fs = require 'fs'
stream = require 'stream'

{Count, AminoAcidSequence, DNASequence} = require '../lib/mutation-optimizer'

fs.readFile '../biobrick/out-file-seqs.json', (err, data) ->
  throw err if err
  seqs = JSON.parse data.toString()
  seqKeys = Object.keys seqs
  makeLogFromPart = (part) ->
    # take only the first from sequences
    seq = seqs[part][0]
    splitSeq = Count.splitCodons seq
    rateLimitingCodons: Count.rateLimitingCodons splitSeq
    antiShineDelgarno: Count.antiShineDelgarno seq
    ttDimerCount: Count.ttDimerCount seq
    otherPyrDimerCount: Count.otherPyrDimerCount seq
    weightedPyrDimerCount: Count.weightedPyrDimerCount seq
    methylationSites: Count.methylationSites seq
    repeatRuns: Count.repeatRuns seq
    deaminationSites: Count.deaminationSites seq
    alkylationSites: Count.alkylationSites seq
    oxidationSites: Count.oxidationSites seq
    miscSites: Count.miscSites seq
    hairpinSites: Count.hairpinSites seq
    insertionSequences: Count.insertionSequences seq
  # do this for the ones that pass amino acid checking, and also the ones that
  # pass dna checking
  aminoCheckStream = new stream.PassThrough
  aminoCheckStream.pipe fs.createWriteStream 'out-counts-amino.json'
  dnaCheckStream = new stream.PassThrough
  dnaCheckStream.pipe fs.createWriteStream 'out-counts-dna.json'

  aminoCheckStream.write '{\n'
  aminoCheckParts = seqKeys.filter (part) ->
    try
      (new DNASequence seqs[part][0]).toAminoSeq().clean()
      return yes
    catch
      return no
  firstAminoPart = aminoCheckParts[0]
  aminoCheckStream.write "\"#{firstAminoPart}\":
  #{JSON.stringify makeLogFromPart firstAminoPart}\n"
  aminoCheckParts[1..].forEach (part) ->
    aminoCheckStream.write ",\"#{part}\":
    #{JSON.stringify makeLogFromPart part}\n"
  aminoCheckStream.write '}\n'

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
  dnaCheckParts[1..].forEach (part) ->
    dnaCheckStream.write ",\"#{part}\":
    #{JSON.stringify makeLogFromPart part}\n"
  dnaCheckStream.write '}\n'
