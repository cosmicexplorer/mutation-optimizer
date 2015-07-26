# not sure how best to structure this but i think a more functional style will
# make it easier down the road, so top-level objects are basically just
# namespaces for now

# all functions should take and return arrays so we can do mutable operations
# more easily and quickly. bounce to string and back if you need regex

# (the above comments are mostly for me, please don't feel like you have to
# follow them)

class SequenceError
  constructor: (@message, @type) ->

insertIntoIfNotExist = (strOrArr, opts) ->
  { beg, end } = opts
  strOrArr = beg + strOrArr if beg and strOrArr[0] isnt beg
  strOrArr = strOrArr + end if end and strOrArr[strOrArr.length - 1] isnt end
  strOrArr

AminoAcidSequence =
  ValidIUPACSyms: ['W','L','P','H','Q','R','I','M','T','N','K','S','V','A','D',
    'E','G','F','Y','C','-']
  StopCodonSyms: ['*','X','-']

  cleanSeq: (seq) ->
    symCleaned = seq.map (sym) ->
      if sym not in AminoAcidSequence.ValidIUPACSyms
        throw new SequenceError 'Invalid IUPAC symbols', AminoAcidSequence
      else if sym in AminoAcidSequence.StopCodonSyms then '-'
      else sym
    insertIntoIfNotExist symCleaned,
      beg: 'M'
      end: '-'
