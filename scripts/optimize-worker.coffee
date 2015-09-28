Opt = require '../lib/mutation-optimizer'

getSequenceOpt = (state) ->
  aminoSeq = switch state.inputType
    when 'DNA' then (new Opt.DNASequence state.inputText).toAminoSeq()
    when 'Amino' then new Opt.AminoAcidSequence state.inputText
    else throw new Opt.SequenceError "sequence type invalid", "bad seq type"
  weights = if state.isDefaultChecked then null else state.parameterizedOptions
  console.log [weights, state.advancedOptions]
  aminoSeq.minimizeMutation {weights, adv: state.advancedOptions}

makeError = (txt) -> {err: yes, txt: txt}

handleMessage = ({data: state, cb = self.postMessage}) ->
  if state.invalidState
    cb makeError "invalid state"
    return
  try
    weights = if state.isDefaultChecked then null else
      state.parameterizedOptions
    newSeq = (getSequenceOpt state).seq
    newSeqScore = Opt.Count.MutabilityScore newSeq, newSeq, {weights}
    oldSeq = state.inputText
    [oldSeqScore, oldIndices] = switch state.inputType
      when 'DNA' then [Opt.Count.MutabilityScore oldSeq, oldSeq, {weights}
        Opt.Count.HotspotIndices oldSeq, oldSeq]
      when 'Amino' then [null, null]
    res =
      oldSeqObj:
        seq: oldSeq
        score: oldSeqScore
        indices: oldIndices
      newSeqObj:
        seq: newSeq
        score: newSeqScore
        indices: Opt.Count.HotspotIndices newSeq, newSeq
      type: state.inputType
    # console.log res
    cb res
  catch err
    cb makeError err

self.onmessage = handleMessage

module.exports = handleMessage
