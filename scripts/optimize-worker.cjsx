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
  self.postMessage makeError "invalid state" if e.invalidState
  state = e.data
  try
    weights = if state.isDefaultChecked then null else
      state.parameterizedOptions
    newSeq = (getSequenceOpt state).seq
    newSeqScore = Opt.Count.MutabilityScore newSeq, newSeq, {weights}
    oldSeq = state.inputText
    oldSeqScore = Opt.Count.MutabilityScore oldSeq, oldSeq, {weights}
    self.postMessage
      oldSeqObj:
        seq: oldSeq
        score: oldSeqScore
      newSeqObj:
        seq: newSeq
        score: newSeqScore
      type: state.inputType
  catch err
    self.postMessage makeError err
