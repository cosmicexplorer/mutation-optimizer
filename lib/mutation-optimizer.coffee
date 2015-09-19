utils = require './utils'
symbols = require './symbols'

CODON_LENGTH = 3

class SequenceError
  constructor: (@message, @type) ->

### SEQ CHECK IMPROVEMENTS
- make orf finder, and only act upon each orf in sequence, not sequence as a
whole since sequence may not begin/end on orf boundary
- check if there appears to be at least one orf >= 20 bases in length

- get at least 2-3k valid seqs for counting; if not, then attempt to apply above
###

class Sequence
  err: (str) -> throw new SequenceError str, @constructor.name
  check: (seq) -> seq
  constructor: (seq) ->
    # coerce to string
    @seq = (if seq.constructor is Array then seq.join '' else seq).toUpperCase()
  clean: ->
    cst = @constructor
    cleaned = @seq.split('').map((sym) =>
      if cst.ValidIUPACSyms.indexOf(sym) is -1
        @err "non-IUPAC symbol: #{sym}"
      cst.TransformSyms[sym] or sym).join ''
    @fixEnds @check(cleaned), cst.FixEndOpts
  fixEnds: (strOrArr, opts) -> strOrArr
    # TODO: fix/reinstate this
    # {beg, end, doThrow} = opts
    # if beg
    #   activeStr = strOrArr[..(beg.len - 1)]
    #   if beg.text.indexOf(activeStr) is -1
    #     @err "Error at beginning of sequence #{activeStr}" if doThrow
    #     strOrArr = beg[0] + strOrArr
    # if end
    #   activeStr = strOrArr[(-end.len)..]
    #   if end.text.indexOf(activeStr) is -1
    #     @err "Error at end of sequence #{activeStr}" if doThrow
    #     strOrArr = strOrArr + end[0]
    # strOrArr

ORF_THRESHOLD = 100

getMinCount = (a, b) -> if a.count < b.count then a else b

class AminoAcidSequence extends Sequence
  @ValidIUPACSyms: symbols.AminoIUPAC
  @TransformSyms: symbols.AminoTransform
  @FixEndOpts:
    beg:
      len: 1
      text: symbols.AminoStartCodons
    end:
      len: 1
      text: symbols.AminoEndCodons
  findPossibleORFs: (seq) ->
    beg = 0
    end = 0
    indices = []
    while (beg = seq.indexOf('M', end)) isnt -1
      end = seq.indexOf '-', beg + 1
      if end is -1
        break
      else
        indices.push {beg: beg, end: end}
    indices
  check: (seq) ->
    getDist = (index) ->
      {beg, end} = index
      end - beg
    getMaxDist = (prev, indexB) ->
      dist = getDist indexB
      if dist > prev then dist
    biggestPossibleORF = @findPossibleORFs(seq).reduce(getMaxDist, 0)
    if biggestPossibleORF < ORF_THRESHOLD
      @err "orf of length >= #{ORF_THRESHOLD} not found by heuristic"
    seq

  @MutationWindowLength: 3
  # singleWeight is a single function to use for optimization; if not given, it
  # optimizes using the weights given in symbols.FunctionWeights
  minimizeMutation: ({singleWeight = null, cleanedSeq = null} = {}) ->
    aminoString = cleanedSeq or @clean().split ''
    finalString = new Array aminoString.length
    # TODO: consider version where we greedily choose current index of codon
    # based on sum of weights of all codon combinations it's contained in,
    # instead of just the codon combination with the least weight
    finalInd = aminoString.length - @constructor.MutationWindowLength + 1
    # console.log aminoString[0..5]
    for i in [0..(finalInd - 1)] by 1
      intermed = aminoString[i..(i + @constructor.MutationWindowLength)]
        .map((el) -> symbols.DNACodonAminoMap[el])
      console.log aminoString unless intermed[0]
      finalString[i] = intermed.getAllCombinations()
        .map((codonSeq) ->
          first: codonSeq[0]
          count: Count.MutabilityScore(
            codonSeq.join(''), finalString[..(i - 1)], singleWeight))
        .reduce(getMinCount)
        .first
    aminoString[finalInd..(finalInd + @constructor.MutationWindowLength - 1)]
      .map((el) -> symbols.DNACodonAminoMap[el])
      .getAllCombinations()
      .map((codonSeq) ->
        seq: codonSeq
        count: Count.MutabilityScore(codonSeq.join ''))
      .reduce(getMinCount).seq.forEach (el, ind) ->
        finalString[finalInd + ind] = el
    new DNASequence finalString.join ''

  minimizeAllMutations: (orig) ->
    orig =
      name: 'original'
      counts: Count.AllCounts orig
    cleaned = @clean().split ''
    specificallyOptimizedSequences = Count.AllFuns.map (f) =>
      name: f.name
      counts: Count.AllCounts (@minimizeMutation
        singleWeight: f.func
        cleanedSeq: cleaned).seq
    globallyOptimized =
      name: 'global'
      counts: Count.AllCounts @minimizeMutation().seq
    res = {}
    specificallyOptimizedSequences.concat([orig, globallyOptimized])
      .forEach (el) -> res[el.name] = el.counts
    res

# TODO: consider using cached search tree or something if countOccurrences ends
# up needing a bit more speed
# TODO: reverse complement all of these from symbols instead of using them
# directly
# TODO: add homology repeats once mutation-optimization implemented
class Count
  @DefaultHomologyCount: 5
  @RepeatRunCount: 4
  # all sequences here are assumed to be strings!!!
  @WeightedPyrDimerMap: (->
    dimers = utils.ConvoluteKeysValues symbols.WeightedPyrDimers
    v = parseFloat v for k, v of dimers
    dimers)()
  @countOccurrences: (containerSet, symbolSet) ->
    symbolSet.map((el) -> containerSet.countSubstr el).sum()
  @splitCodons: (seq) -> seq.splitLength CODON_LENGTH

  # counts ensue
  @rateLimitingCodons: (seq) => @splitCodons(seq).filter((el) ->
    symbols.RateLimitingCodons.indexOf(el) isnt -1).length
  # DIFFERS FROM PY AT ds[0] because of indexing
  @antiShineDelgarno: (seq) =>
    @countOccurrences seq, symbols.AntiShineDelgarno
  @ttDimerCount: (seq) =>
    @countOccurrences seq, symbols.TTDimers
  @otherPyrDimerCount: (seq) =>
    @countOccurrences seq, symbols.OtherPyrDimers
  @weightedPyrDimerCount: (seq) =>
    (v * seq.countSubstr k for k, v of @WeightedPyrDimerMap).sum()
  @methylationSites: (seq) =>
    @countOccurrences seq, symbols.MethylationSites
  @repeatRuns: (seq, unused, count = @RepeatRunCount) =>
    totalRuns = 0
    prevChar = null
    curRun = 0
    for ch in seq
      if ch is prevChar then ++curRun else curRun = 0
      if curRun >= (count - 1) then ++totalRuns
      prevChar = ch
    totalRuns
  # TODO: find more meaningful representation of this, also optimize
  @homologyRepeatCount: (seq, currentSeq, count = @DefaultHomologyCount) =>
    numRepeats = 0
    for i in [0..(seq.length - count)] by 1
      # assume sequence is only composed of A, C, T, G
      reg = new RegExp seq[i..(i + count - 1)], 'gi'
      ++numRepeats if (seq.match(reg) or []).length > 0
    numRepeats
  @deaminationSites: (seq) => @countOccurrences seq, symbols.DeaminationSites
  # DIFFERS FROM PY AT ds[0] because of indexing
  @alkylationSites: (seq) => @countOccurrences seq, symbols.AlkylationSites
  @oxidationSites: (seq) => @countOccurrences seq, symbols.OxidationSites
  @miscSites: (seq) => @countOccurrences seq, symbols.MiscSites
  # DIFFERS FROM PY AT ds[0] because of indexing
  @hairpinSites: (seq) =>
    symbols.HairpinSites.map((reg) -> (seq.match(reg) or []).length).sum()
  @insertionSequences: (seq) =>
    @countOccurrences seq, symbols.InsertionSequences
  @RFC10Sites: (seq) => @countOccurrences seq, symbols.RFC10Sites

  @AllFuns: for k, v of symbols.FunctionWeights
    {func: @[v.func], weight: v.weight, name: v.func}
  @AllCounts: (seq, constrSeq = seq) =>
    res = {}
    sum = 0
    for el in @AllFuns
      cur = el.func seq, constrSeq
      sum += cur * el.weight
      res[el.name] = cur
    res.mutability_score = sum
    res
  @MutabilityScore: (seq, constrSeq, singleWeight) =>
    if singleWeight then singleWeight seq, constrSeq else
      @AllFuns.map((w) -> w.func(seq, constrSeq) * w.weight).sum()

class DNASequence extends Sequence
  @ValidIUPACSyms: symbols.DNAIUPAC
  @CodonAminoMap: utils.ConvoluteKeysValues symbols.DNACodonAminoMap
  @TransformSyms: symbols.DNATransformSyms
  @StartCodons: symbols.StartCodons
  @StopCodons: symbols.StopCodons
  @FixEndOpts:
    beg:
      len: 3
      text: @StartCodons
    end:
      len: 3
      text: @StopCodons
    doThrow: on

  check: (seq) ->
    @err "not multiple of 3: #{seq.length}" if seq.length % 3
    @constructor.StopCodons.forEach (codon) =>
      ind = seq.indexOf codon
      if ind > 0 and ind < seq.length - 3 and ind % 3 is 0
        @err "Premature stop codon #{codon} at index #{ind}"
    seq

  toAminoSeqFromSplit: (splitSeq) ->
    new AminoAcidSequence splitSeq.map (codon) =>
      @constructor.CodonAminoMap[codon] or @err "codon #{codon} is invalid"

  toAminoSeq: ->
    @toAminoSeqFromSplit Count.splitCodons @seq

# fs = require 'fs'
# seqs = null
# seqKeys = null
# ds = null
# fs.readFile '../biobrick/out-file-seqs.json', (err, data) ->
#   throw err if err
#   seqs = JSON.parse data.toString()
#   seqKeys = Object.keys seqs
#   ds = seqKeys.map (el) -> new DNASequence seqs[el][0]

# goodPartFilter = (el) ->
#   seq = new DNASequence seqs[el][0]
#   try
#     seq.clean()
#     return yes
#   catch
#     return no

# aminoPartFilter = (el) ->
#   try
#     seq = (new DNASequence seqs[el][0]).toAminoSeq().clean()
#     return yes
#   catch
#     return no

module.exports =
  AminoAcidSequence: AminoAcidSequence
  DNASequence: DNASequence
  Count: Count

red = (a, b) ->
  a[k] = (a[k] or 0) + v for k, v of b
  a

dnaComplete = (Object.keys dnaParts).map((el) ->
  el = dnaParts[el]
  res = {}
  for k, v of el.original
    res[k] = v - el.global[k]
  res).reduce red, {}

aminoComplete = (Object.keys aminoParts).map((el) ->
  el = aminoParts[el]
  res = {}
  for k, v of el.original
    res[k] = v - el.global[k]
  res).reduce red, {}
