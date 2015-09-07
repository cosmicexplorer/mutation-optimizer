utils = require './utils'
symbols = require './symbols'
mixins = require 'coffeescript-mixins'
mixins.bootstrap()

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
    cleaned = @seq.split('').map((sym) ->
      @err "non-IUPAC symbol: #{sym}" unless cst.ValidIUPACSyms[sym]
      cst.TransformSyms[sym] or sym).join ''
    @fixEnds @check(cleaned), cst.FixEndOpts
  fixEnds: (strOrArr, opts) ->
    {beg, end, doThrow} = opts
    if beg
      activeStr = strOrArr[..(beg.len - 1)]
      if not beg.text[activeStr]
        @err "Error at beginning of sequence #{activeStr}" if doThrow
        strOrArr = beg + strOrArr
    if end
      activeStr = strOrArr[(-end.len)..]
      if not end.text[activeStr]
        @err "Error at end of sequence #{activeStr}" if doThrow
        strOrArr = strOrArr + end
    strOrArr

class AminoAcidSequence extends Sequence
  @ValidIUPACSyms: symbols.AminoIUPAC
  @TransformSyms: symbols.AminoTransform
  @FixEndOpts:
    beg:
      len: 1
      text: ['M']
    end:
      len: 1
      text: ['-']
  check: (seq) ->
    @err "orf of length >= 20 not found by heuristic" if seq.indexOf '-' < 20
    seq

  # minimizeMutation: ->
  #   @clean().map

# TODO: consider using cached search tree or something if countOccurrences ends
# up needing a bit more speed
# TODO: reverse complement all of these
# TODO: homology repeats once mutation-optimization implemented
class Count
  # all sequences here must be strings!!!
  @WeightedPyrDimerMap: (->
    dimers = utils.ConvoluteKeysValues symbols.WeightedPyrDimers
    v = parseFloat v for k, v of dimers
    dimers)()
  countOccurrences: (containerSet, symbolSet) ->
    symbolSet.map((el) -> containerSet.countSubstr el).sum()
  splitCodons: (seq) ->
    seq.splitLength CODON_LENGTH
  rateLimitingCodons: (splitSeq) ->
    splitSeq.filter((el) -> symbols.RateLimitingCodons[el]).length
  antiShineDelgarno: (seq) ->
    @countOccurrences seq, symbols.AntiShineDelgarno
  ttDimerCount: (seq) ->
    @countOccurrences seq, symbols.TTDimers
  otherPyrDimerCount: (seq) ->
    @countOccurrences seq, symbols.OtherPyrDimers
  weightedPyrDimerCount: (seq) ->
    total = 0
    for k, v of @constructor.WeightedPyrDimerMap
      total += seq.countSubstr k, v
    total
  methylationSites: (seq) ->
    @countOccurrences seq, symbols.MethylationSites
  repeatRuns: (seq) ->
    totalRuns = 0
    prevChar = null
    curRun = 0
    for ch in seq
      if ch is prevChar then ++curRun else curRun = 0
      if curRun is 4 then ++totalRuns
      prevChar = ch
    totalRuns
  deaminationSites: (seq) -> @countOccurrences seq, symbols.DeaminationSites
  alkylationSites: (seq) -> @countOccurrences seq, symbols.AlkylationSites
  oxidationSites: (seq) -> @countOccurrences seq, symbols.OxidationSites
  miscSites: (seq) -> @countOccurrences seq, symbols.MiscSites
  insertionSequences: (seq) -> @countOccurrences seq, symbols.InsertionSequences

class DNASequence extends Sequence
  @include Count
  @ValidIUPACSyms: symbols.DNAIUPAC
  @CodonAminoMap: utils.ConvoluteKeysValues symbols.DNACodonAminoMap
  @TransformSyms: symbols.DNATransformSyms

  @StartCodons: symbols.StartCodons
  @StopCodons: symbols.StopCodons

  @FixEndOpts:
    beg:
      len: 3
      text: @constructor.StartCodons
    end:
      len: 3
      text: @constructor.StopCodons
    doThrow: on

  check: (seq) ->
    @err "not multiple of 3: #{seq.length}" if seq.length % 3
    @constructor.StopCodons.forEach (codon) ->
      ind = seq.indexOf codon
      if ind > 0 and ind < seq.length - 3 and ind % 3 is 0
        @err "Premature stop codon #{codon} at index #{ind}"
    seq

  toAminoSeqFromSplit: (splitSeq) ->
    new AminoAcidSequence splitSeq.map (codon) ->
      @constructor.CodonAminoMap[codon] or @err "codon #{codon} is invalid"

  toAminoSeq: ->
    @toAminoSeqFromSplit @splitCodons @clean()
