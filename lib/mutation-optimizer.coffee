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

  # minimizeMutation: ->
  #   @clean().map

# TODO: consider using cached search tree or something if countOccurrences ends
# up needing a bit more speed
# TODO: reverse complement all of these from symbols instead of using them
# directly
# TODO: add homology repeats once mutation-optimization implemented
class Count
  # all sequences here are assumed to be strings!!!
  @WeightedPyrDimerMap: (->
    dimers = utils.ConvoluteKeysValues symbols.WeightedPyrDimers
    v = parseFloat v for k, v of dimers
    dimers)()
  @countOccurrences: (containerSet, symbolSet) ->
    symbolSet.map((el) -> containerSet.countSubstr el).sum()
  @splitCodons: (seq) ->
    seq.splitLength CODON_LENGTH
  # counts ensue
  @rateLimitingCodons: (splitSeq) ->
    splitSeq.filter((el) ->
      symbols.RateLimitingCodons.indexOf(el) isnt -1).length
  # DIFFERS FROM PY AT ds[0] because of indexing
  @antiShineDelgarno: (seq) ->
    @countOccurrences seq, symbols.AntiShineDelgarno
  @ttDimerCount: (seq) ->
    @countOccurrences seq, symbols.TTDimers
  @otherPyrDimerCount: (seq) ->
    @countOccurrences seq, symbols.OtherPyrDimers
  @weightedPyrDimerCount: (seq) ->
    (v * seq.countSubstr k for k, v of @WeightedPyrDimerMap).sum()
  @methylationSites: (seq) ->
    @countOccurrences seq, symbols.MethylationSites
  @repeatRuns: (seq) ->
    totalRuns = 0
    prevChar = null
    curRun = 0
    for ch in seq
      if ch is prevChar then ++curRun else curRun = 0
      if curRun >= 3 then ++totalRuns
      prevChar = ch
    totalRuns
  @deaminationSites: (seq) -> @countOccurrences seq, symbols.DeaminationSites
  # DIFFERS FROM PY AT ds[0] because of indexing
  @alkylationSites: (seq) -> @countOccurrences seq, symbols.AlkylationSites
  @oxidationSites: (seq) -> @countOccurrences seq, symbols.OxidationSites
  @miscSites: (seq) -> @countOccurrences seq, symbols.MiscSites
  # DIFFERS FROM PY AT ds[0] because of indexing
  @hairpinSites: (seq) ->
    symbols.HairpinSites.map((reg) -> (seq.match(reg) or []).length).sum()
  @insertionSequences: (seq) ->
    @countOccurrences seq, symbols.InsertionSequences

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
