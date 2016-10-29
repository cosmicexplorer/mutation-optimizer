var Opt, getSequenceOpt, handleMessage, makeError;

Opt = require('../lib/mutation-optimizer');

getSequenceOpt = function(state) {
  var aminoSeq, weights;
  aminoSeq = (function() {
    switch (state.inputType) {
      case 'DNA':
        return (new Opt.DNASequence(state.inputText)).toAminoSeq();
      case 'Amino':
        return new Opt.AminoAcidSequence(state.inputText);
      default:
        throw new Opt.SequenceError("sequence type invalid", "bad seq type");
    }
  })();
  weights = state.isDefaultChecked ? null : state.parameterizedOptions;
  return aminoSeq.minimizeMutation({
    weights: weights,
    adv: state.advancedOptions
  });
};

makeError = function(txt) {
  return {
    err: true,
    txt: txt
  };
};

handleMessage = function(arg) {
  var cb, err, error, newSeq, newSeqScore, oldIndices, oldSeq, oldSeqScore, ref, ref1, res, state, weights;
  state = arg.data, cb = (ref = arg.cb) != null ? ref : self.postMessage;
  if (state.invalidState) {
    cb(makeError("invalid state"));
    return;
  }
  try {
    weights = state.isDefaultChecked ? null : state.parameterizedOptions;
    newSeq = (getSequenceOpt(state)).seq;
    newSeqScore = Opt.Count.MutabilityScore(newSeq, newSeq, {
      weights: weights
    });
    oldSeq = state.inputText;
    ref1 = (function() {
      switch (state.inputType) {
        case 'DNA':
          return [
            Opt.Count.MutabilityScore(oldSeq, oldSeq, {
              weights: weights
            }), Opt.Count.HotspotIndices(oldSeq, oldSeq)
          ];
        case 'Amino':
          return [null, null];
      }
    })(), oldSeqScore = ref1[0], oldIndices = ref1[1];
    res = {
      oldSeqObj: {
        seq: oldSeq,
        score: oldSeqScore,
        indices: oldIndices
      },
      newSeqObj: {
        seq: newSeq,
        score: newSeqScore,
        indices: Opt.Count.HotspotIndices(newSeq, newSeq)
      },
      type: state.inputType
    };
    return cb(res);
  } catch (error) {
    err = error;
    return cb(makeError(err));
  }
};

self.onmessage = handleMessage;

module.exports = handleMessage;
