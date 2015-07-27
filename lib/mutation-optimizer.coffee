# not sure how best to structure this but i think a more functional style will
# make it easier down the road, so top-level objects are basically just
# namespaces for now

# all functions should take and return arrays so we can do mutable operations
# more easily and quickly. bounce to string and back if you need regex

# (the above comments are mostly for me, please don't feel like you have to
# follow them)

class SequenceError
  constructor: (@message, @type) ->

class Sequence
  err: (str) -> throw new SequenceError str, @constructor.name
  check: (seq) -> seq
  constructor: (@seq) ->
  clean: ->
    cst = @constructor
    cleaned = @seq.split('').map((sym) ->
      @err "non-IUPAC symbol: #{sym}" if cst.ValidIUPACSyms?.has sym
      cst.TransformSyms?.get sym or sym).join ''
    @fixEnds? @check(cleaned), cst.FixEndOpts
  fixEnds: (strOrArr, opts) ->
    { beg, end, doThrow } = opts
    if beg
      activeStr = strOrArr[..(beg.len - 1)]
      if not beg.text.has activeStr
        @err "Error at beginning of sequence #{activeStr}" if doThrow
        strOrArr = beg + strOrArr
    if end
      activeStr = strOrArr[(-end.len)..]
      if not end.text.has activeStr
        @err "Error at end of sequence #{activeStr}" if doThrow
        strOrArr = strOrArr + end
    strOrArr

class AminoAcidSequence
  constructor: (@seq) ->
  @ValidIUPACSyms: new Set ['W','L','P','H','Q','R','I','M','T','N','K','S','V',
    'A','D','E','G','F','Y','C','-']
  @TransformSyms: new Map ['*': '-', 'X': '-']
  @FixEndOpts:
    beg:
      len: 1
      text: new Set ['M']
    end:
      len: 1
      text: new Set ['-']

class DNASequence
  @ValidIUPACSyms: ['A','T','G','C','U','R','Y','N']
  @TransformSyms: new Map ['U': 'T']

  @StartCodons: ['ATG']
  @StopCodons: ['TGA', 'TAG', 'TAA']

  @FixEndOpts:
    beg:
      len: 3
      text: new Set @constructor.StartCodons
    end:
      len: 3
      text: new Set @constructor.StopCodons
    doThrow: on

  check: (seq) ->
    @err "not multiple of 3: #{seq.length}" if seq.length % 3
    @constructor.StopCodons.forEach (codon) ->
      ind = seq.indexOf codon
      if ind > 0 and ind < seq.length - 3 and ind % 3 is 0
        @err "Premature stop codon #{codon} at index #{ind}"
    seq
