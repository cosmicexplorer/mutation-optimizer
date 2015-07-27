utils = require './utils'
symbols = require './symbols'

CODON_LENGTH = 3

class SequenceError
  constructor: (@message, @type) ->

class Sequence
  err: (str) -> throw new SequenceError str, @constructor.name
  check: (seq) -> seq
  constructor: (seq) ->
    @seq = if seq.constructor is Array
        seq.map (el) -> el.toUpperCase()
      else seq.toUpperCase().split ''
  clean: ->
    cst = @constructor
    cleaned = @seq.map((sym) ->
      @err "non-IUPAC symbol: #{sym}" if cst.ValidIUPACSyms?.has sym
      cst.TransformSyms?.get sym or sym).join ''
    @fixEnds @check(cleaned), cst.FixEndOpts
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
  @ValidIUPACSyms: new Set symbols.AminoIUPAC
  @TransformSyms: new Map symbols.AminoTransform
  @FixEndOpts:
    beg:
      len: 1
      text: new Set ['M']
    end:
      len: 1
      text: new Set ['-']

class DNASequence
  @ValidIUPACSyms: symbols.DNAIUPAC
  @CodonAminoMap: new Map utils.ConvoluteKeysValues symbols.DNACodonAminoMap
  @TransformSyms: new Map symbols.DNATransformSyms

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

  toAminoSeq: ->
    new AminoAcidSequence @clean().splitLength(CODON_LENGTH).map (codon) ->
      @constructor.CodonAminoMap.get(codon) or @err "codon #{codon} is invalid"
