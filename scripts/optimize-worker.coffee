Opt = require '../lib/mutation-optimizer'

getSequenceOpt = (state) ->
  aminoSeq = switch state.inputType
    when 'DNA' then (new Opt.DNASequence state.inputText).toAminoSeq()
    when 'Amino' then new Opt.AminoAcidSequence @state.inputText
    else throw new Opt.SequenceError "sequence type invalid", "bad seq type"
  weights = if state.isDefaultChecked then null else state.parameterizedOptions
  aminoSeq.minimizeMutation weights

makeError = (txt) -> {err: yes, txt: txt}

self.onmessage = (e) ->
  if e.data.invalidState
    self.postMessage makeError "invalid state"
    return
  state = e.data
  try
    weights = if state.isDefaultChecked then null else
      state.parameterizedOptions
    newSeq = (getSequenceOpt state).seq
    newSeqScore = Opt.Count.MutabilityScore newSeq, newSeq, {weights}
    oldSeq = state.inputText
    oldSeqScore = switch state.inputType
      when 'DNA' then Opt.Count.MutabilityScore oldSeq, oldSeq, {weights}
      when 'Amino' then null
    res =
      oldSeqObj:
        seq: oldSeq
        score: oldSeqScore
        indices: Opt.Count.HotspotIndices oldSeq, oldSeq
      newSeqObj:
        seq: newSeq
        score: newSeqScore
        indices: Opt.Count.HotspotIndices newSeq, newSeq
      type: state.inputType
    console.log res
    self.postMessage res
  catch err
    self.postMessage makeError err
