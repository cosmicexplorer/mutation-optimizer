utils = require './utils'
symbols = require './symbols'

CODON_LENGTH = 3


class SequenceError extends Error
  constructor: (@message, @type) ->
    super @message

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
  # weights is an associative object mapping the "title" of each weight given in
  # symbols.FunctionWeights to a floating-point number
  minimizeMutation: ({singleWeight = null, cleanedSeq = null,
    weights = null} = {}) ->
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
      # console.log aminoString unless intermed[0]
      finalString[i] = intermed.getAllCombinations()
        .map((codonSeq) ->
          first: codonSeq[0]
          count: Count.MutabilityScore(
            codonSeq.join(''), finalString[..(i - 1)], {singleWeight, weights}))
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


# TODO: reverse complement all of these from symbols instead of using them
# directly
class Count
  @DefaultHomologyCount: 5
  @RepeatRunCount: 4
  # all sequences here are assumed to be strings!!!
  @WeightedPyrDimerMap: do ->
    dimers = utils.ConvoluteKeysValues symbols.WeightedPyrDimers
    v = parseFloat v for k, v of dimers
    dimers
  @WeightedPyrDimerSet: k for k of @WeightedPyrDimerMap
  @occurrenceIndices: (containerSet, symbolSet) ->
    res = {}
    for el in symbolSet
      res[el] = containerSet.indicesOfOccurrences el
    res
  @countOccurrences: (containerSet, symbolSet) ->
    symbolSet.map((el) -> containerSet.countSubstr el).sum()
  @countOrInd: (containerSet, symbolSet, ind) ->
    if ind then @occurrenceIndices containerSet, symbolSet
    else @countOccurrences containerSet, symbolSet
  @splitCodons: (seq) -> seq.splitLength CODON_LENGTH

  # counts ensue
  @rateLimitingCodons: (seq, ind) =>
    if ind then @occurrenceIndices @splitCodons(seq), symbols.RateLimitingCodons
    else @splitCodons(seq).filter((el) ->
      symbols.RateLimitingCodons.indexOf(el) isnt -1).length
  # DIFFERS FROM PY AT ds[0] because of indexing
  @antiShineDelgarno: (seq, ind) =>
    @countOrInd seq, symbols.AntiShineDelgarno, ind
  @ttDimerCount: (seq, ind) =>
    @countOrInd seq, symbols.TTDimers, ind
  @otherPyrDimerCount: (seq, ind) =>
    @countOrInd seq, symbols.OtherPyrDimers, ind
  @weightedPyrDimerCount: (seq, ind) =>
    if ind then @occurrenceIndices seq, @WeightedPyrDimerSet
    else (v * seq.countSubstr k for k, v of @WeightedPyrDimerMap).sum()
  @methylationSites: (seq, ind) =>
    @countOrInd seq, symbols.MethylationSites, ind
  @repeatRuns: (seq, ind) =>
    totalRuns = 0
    prevChar = null
    curRun = 0
    inds = [] if ind
    for ch, i in seq
      if ch is prevChar then ++curRun
      else
        if (curRun >= (@RepeatRunCount - 1) and ind)
          curInd = i - curRun
          inds.push
            start: curInd
            str: seq[(curInd)..(curInd + curRun - 1)]
        curRun = 0
      if (curRun >= (@RepeatRunCount - 1) and not ind) then ++totalRuns
      prevChar = ch
    if ind then inds else totalRuns
  # TODO: find more meaningful representation of this, also optimize
  @homologyRepeatCount: (seq, currentSeq, ind) =>
    numRepeats = 0 unless ind
    inds = [] if ind
    for i in [@DefaultHomologyCount..(seq.length - @DefaultHomologyCount)] by 1
      # assume sequence is only composed of A, C, T, G
      str = currentSeq[i..(i + @DefaultHomologyCount - 1)]
      upperInd = (currentSeq.indexOf str, i + 1)
      lowerInd = currentSeq[0..(i + @DefaultHomologyCount - 2)].indexOf str
      if (lowerInd isnt -1) or
         (upperInd isnt -1)
        if ind then inds.push {start: i, str: str} else ++numRepeats
    if ind then inds else numRepeats
  @deaminationSites: (seq, ind) =>
    @countOrInd seq, symbols.DeaminationSites, ind
  # DIFFERS FROM PY AT ds[0] because of indexing
  @alkylationSites: (seq, ind) => @countOrInd seq, symbols.AlkylationSites, ind
  @oxidationSites: (seq, ind) => @countOrInd seq, symbols.OxidationSites, ind
  @miscSites: (seq, ind) => @countOrInd seq, symbols.MiscSites, ind
  # DIFFERS FROM PY AT ds[0] because of indexing
  @hairpinSites: (seq, ind) =>
    sites = symbols.HairpinSites
    if ind
      res = {}
      for reg in sites
        res[reg] = (match.index while (match = (reg.exec seq)?))
      res
    else sites.map((reg) -> (seq.match(reg) or []).length).sum()
  @insertionSequences: (seq, ind) =>
    @countOrInd seq, symbols.InsertionSequences, ind
  @RFC10Sites: (seq, ind) => @countOrInd seq, symbols.RFC10Sites, ind

  @AllFuns: for k, v of symbols.FunctionWeights
    f = @[v.func]
    func: if v.needsCurSeq then f else do (f) -> (seq, constrSeq, ind) ->
      f seq, ind
    weight: v.weight
    name: v.func
    title: k
    inFrame: v.inFrame
  @SumAllWeights: (seq, constrSeq, weights) =>
    @AllFuns.map((if weights
        (f) -> (f.func seq, constrSeq) * weights[f.title]
      else (f) -> (f.func seq, constrSeq) * f.weight)).sum()
  @AllCounts: (seq, constrSeq = seq) =>
    res = {}
    sum = 0
    for el in @AllFunsCleaned
      cur = el.func seq, constrSeq
      sum += cur * el.weight
      res[el.name] = cur
    res.mutability_score = sum
    res
  @MutabilityScore: (seq, constrSeq, {singleWeight = null,
    weights = null} = {}) =>
    seq = seq.toUpperCase()
    constrSeq = seq.toUpperCase()
    if singleWeight then singleWeight seq, constrSeq else
      if weights
        # for weights not given (usually in nonOptions in strings.coffee), we
        # assume the default weights
        for entry in @AllFuns
          weights[entry.title] = entry.weight unless weights[entry.title]
      @SumAllWeights seq, constrSeq, weights
  @HotspotIndices: (seq, constrSeq) =>
    seq = seq.toUpperCase()
    constrSeq = constrSeq.toUpperCase()
    @AllFuns.map (f) ->
      indices: f.func seq, constrSeq, yes
      title: f.title


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

# module.exports =
#   AminoAcidSequence: AminoAcidSequence
#   DNASequence: DNASequence
#   Count: Count

# red = (a, b) ->
#   a[k] = (a[k] or 0) + v for k, v of b
#   a

# dnaComplete = (Object.keys dnaParts).map((el) ->
#   el = dnaParts[el]
#   res = {}
#   for k, v of el.original
#     res[k] = v - el.global[k]
#   res).reduce red, {}

# aminoComplete = (Object.keys aminoParts).map((el) ->
#   el = aminoParts[el]
#   res = {}
#   for k, v of el.original
#     res[k] = v - el.global[k]
#   res).reduce red, {}


module.exports = {
  SequenceError
  AminoAcidSequence
  Count
  DNASequence
}
