var AminoAcidSequence, CODON_LENGTH, Count, DNASequence, ORF_THRESHOLD, Sequence, SequenceError, getMinCount, symbols, utils,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

utils = require('./utils');

symbols = require('./symbols');

CODON_LENGTH = 3;

SequenceError = (function(superClass) {
  extend(SequenceError, superClass);

  function SequenceError(message, type) {
    this.message = message;
    this.type = type;
    SequenceError.__super__.constructor.call(this, this.message);
  }

  return SequenceError;

})(Error);


/* SEQ CHECK IMPROVEMENTS
- make orf finder, and only act upon each orf in sequence, not sequence as a
whole since sequence may not begin/end on orf boundary
- check if there appears to be at least one orf >= 20 bases in length

- get at least 2-3k valid seqs for counting; if not, then attempt to apply above
 */

Sequence = (function() {
  Sequence.prototype.err = function(str) {
    throw new SequenceError(str, this.constructor.name);
  };

  Sequence.prototype.check = function(seq) {
    return seq;
  };

  function Sequence(seq) {
    this.seq = (seq.constructor === Array ? seq.join('') : seq).toUpperCase().replace(/\s/g, "");
  }

  Sequence.prototype.clean = function() {
    var cleaned, cst;
    cst = this.constructor;
    cleaned = this.seq.split('').map((function(_this) {
      return function(sym) {
        if (cst.ValidIUPACSyms.indexOf(sym) === -1) {
          _this.err("non-IUPAC symbol: " + sym);
        }
        return cst.TransformSyms[sym] || sym;
      };
    })(this)).join('');
    return this.fixEnds(this.check(cleaned), cst.FixEndOpts);
  };

  Sequence.prototype.fixEnds = function(strOrArr, opts) {
    return strOrArr;
  };

  return Sequence;

})();

ORF_THRESHOLD = 100;

getMinCount = function(a, b) {
  if (a.count < b.count) {
    return a;
  } else {
    return b;
  }
};

AminoAcidSequence = (function(superClass) {
  extend(AminoAcidSequence, superClass);

  function AminoAcidSequence() {
    return AminoAcidSequence.__super__.constructor.apply(this, arguments);
  }

  AminoAcidSequence.ValidIUPACSyms = symbols.AminoIUPAC;

  AminoAcidSequence.TransformSyms = symbols.AminoTransform;

  AminoAcidSequence.FixEndOpts = {
    beg: {
      len: 1,
      text: symbols.AminoStartCodons
    },
    end: {
      len: 1,
      text: symbols.AminoEndCodons
    }
  };

  AminoAcidSequence.prototype.findPossibleORFs = function(seq) {
    var beg, end, indices;
    beg = 0;
    end = 0;
    indices = [];
    while ((beg = seq.indexOf('M', end)) !== -1) {
      end = seq.indexOf('-', beg + 1);
      if (end === -1) {
        break;
      } else {
        indices.push({
          beg: beg,
          end: end
        });
      }
    }
    return indices;
  };

  AminoAcidSequence.prototype.check = function(seq) {
    var biggestPossibleORF, getDist, getMaxDist;
    getDist = function(index) {
      var beg, end;
      beg = index.beg, end = index.end;
      return end - beg;
    };
    getMaxDist = function(prev, indexB) {
      var dist;
      dist = getDist(indexB);
      if (dist > prev) {
        return dist;
      }
    };
    biggestPossibleORF = this.findPossibleORFs(seq).reduce(getMaxDist, 0);
    if (biggestPossibleORF < ORF_THRESHOLD) {
      this.err("orf of length >= " + ORF_THRESHOLD + " not found by heuristic");
    }
    return seq;
  };

  AminoAcidSequence.MutationWindowLength = 3;

  AminoAcidSequence.prototype.minimizeMutation = function(arg) {
    var adv, aminoString, cleanedSeq, finalInd, finalString, i, intermed, j, ref, ref1, ref2, ref3, ref4, ref5, singleWeight, weights;
    ref = arg != null ? arg : {}, singleWeight = (ref1 = ref.singleWeight) != null ? ref1 : null, cleanedSeq = (ref2 = ref.cleanedSeq) != null ? ref2 : null, weights = (ref3 = ref.weights) != null ? ref3 : null, adv = (ref4 = ref.adv) != null ? ref4 : null;
    aminoString = cleanedSeq || this.clean().split('');
    finalString = new Array(aminoString.length);
    finalInd = aminoString.length - this.constructor.MutationWindowLength + 1;
    for (i = j = 0, ref5 = finalInd - 1; j <= ref5; i = j += 1) {
      intermed = aminoString.slice(i, +(i + this.constructor.MutationWindowLength) + 1 || 9e9).map(function(el) {
        return symbols.DNACodonAminoMap[el];
      });
      finalString[i] = intermed.getAllCombinations().map(function(codonSeq) {
        return {
          first: codonSeq[0],
          count: Count.MutabilityScore(codonSeq.join(''), finalString.slice(0, +(i - 1) + 1 || 9e9), {
            singleWeight: singleWeight,
            weights: weights,
            adv: adv
          })
        };
      }).reduce(getMinCount).first;
    }
    aminoString.slice(finalInd, +(finalInd + this.constructor.MutationWindowLength - 1) + 1 || 9e9).map(function(el) {
      return symbols.DNACodonAminoMap[el];
    }).getAllCombinations().map(function(codonSeq) {
      return {
        seq: codonSeq,
        count: Count.MutabilityScore(codonSeq.join(''))
      };
    }).reduce(getMinCount).seq.forEach(function(el, ind) {
      return finalString[finalInd + ind] = el;
    });
    return new DNASequence(finalString.join(''));
  };

  AminoAcidSequence.prototype.minimizeAllMutations = function(orig) {
    var cleaned, globallyOptimized, res, specificallyOptimizedSequences;
    orig = {
      name: 'original',
      counts: Count.AllCounts(orig)
    };
    cleaned = this.clean().split('');
    specificallyOptimizedSequences = Count.AllFuns.map((function(_this) {
      return function(f) {
        return {
          name: f.name,
          counts: Count.AllCounts((_this.minimizeMutation({
            singleWeight: f.func,
            cleanedSeq: cleaned
          })).seq)
        };
      };
    })(this));
    globallyOptimized = {
      name: 'global',
      counts: Count.AllCounts(this.minimizeMutation().seq)
    };
    res = {};
    specificallyOptimizedSequences.concat([orig, globallyOptimized]).forEach(function(el) {
      return res[el.name] = el.counts;
    });
    return res;
  };

  return AminoAcidSequence;

})(Sequence);

Count = (function() {
  var f, k, v;

  function Count() {}

  Count.DefaultHomologyCount = 5;

  Count.RepeatRunCount = 4;

  Count.WeightedPyrDimerMap = (function() {
    var dimers, k, v;
    dimers = utils.ConvoluteKeysValues(symbols.WeightedPyrDimers);
    for (k in dimers) {
      v = dimers[k];
      v = parseFloat(v);
    }
    return dimers;
  })();

  Count.WeightedPyrDimerSet = (function() {
    var results;
    results = [];
    for (k in Count.WeightedPyrDimerMap) {
      results.push(k);
    }
    return results;
  })();

  Count.occurrenceIndices = function(containerSet, symbolSet) {
    var el, j, len, res;
    res = {};
    for (j = 0, len = symbolSet.length; j < len; j++) {
      el = symbolSet[j];
      res[el] = containerSet.indicesOfOccurrences(el);
    }
    return res;
  };

  Count.countOccurrences = function(containerSet, symbolSet) {
    return symbolSet.map(function(el) {
      return containerSet.countSubstr(el);
    }).sum();
  };

  Count.countOrInd = function(containerSet, symbolSet, ind) {
    if (ind) {
      return this.occurrenceIndices(containerSet, symbolSet);
    } else {
      return this.countOccurrences(containerSet, symbolSet);
    }
  };

  Count.splitCodons = function(seq) {
    return seq.splitLength(CODON_LENGTH);
  };

  Count.rateLimitingCodons = function(seq, ind) {
    if (ind) {
      return Count.occurrenceIndices(Count.splitCodons(seq), symbols.RateLimitingCodons);
    } else {
      return Count.splitCodons(seq).filter(function(el) {
        return symbols.RateLimitingCodons.indexOf(el) !== -1;
      }).length;
    }
  };

  Count.antiShineDelgarno = function(seq, ind) {
    return Count.countOrInd(seq, symbols.AntiShineDelgarno, ind);
  };

  Count.ttDimerCount = function(seq, ind) {
    return Count.countOrInd(seq, symbols.TTDimers, ind);
  };

  Count.otherPyrDimerCount = function(seq, ind) {
    return Count.countOrInd(seq, symbols.OtherPyrDimers, ind);
  };

  Count.weightedPyrDimerCount = function(seq, ind) {
    var v;
    if (ind) {
      return Count.occurrenceIndices(seq, Count.WeightedPyrDimerSet);
    } else {
      return ((function() {
        var ref, results;
        ref = this.WeightedPyrDimerMap;
        results = [];
        for (k in ref) {
          v = ref[k];
          results.push(v * seq.countSubstr(k));
        }
        return results;
      }).call(Count)).sum();
    }
  };

  Count.methylationSites = function(seq, ind) {
    return Count.countOrInd(seq, symbols.MethylationSites, ind);
  };

  Count.repeatRuns = function(seq, ind) {
    var ch, curInd, curRun, i, inds, j, len, prevChar, totalRuns;
    totalRuns = 0;
    prevChar = null;
    curRun = 0;
    if (ind) {
      inds = [];
    }
    for (i = j = 0, len = seq.length; j < len; i = ++j) {
      ch = seq[i];
      if (ch === prevChar) {
        ++curRun;
      } else {
        if (curRun >= (Count.RepeatRunCount - 1) && ind) {
          curInd = i - curRun;
          inds.push({
            start: curInd,
            str: seq.slice(curInd, +(curInd + curRun - 1) + 1 || 9e9)
          });
        }
        curRun = 0;
      }
      if (curRun >= (Count.RepeatRunCount - 1) && !ind) {
        ++totalRuns;
      }
      prevChar = ch;
    }
    if (ind) {
      return inds;
    } else {
      return totalRuns;
    }
  };

  Count.homologyRepeatCount = function(seq, currentSeq, ind) {
    var i, inds, j, lowerInd, numRepeats, ref, ref1, str, upperInd;
    if (!ind) {
      numRepeats = 0;
    }
    if (ind) {
      inds = [];
    }
    for (i = j = ref = Count.DefaultHomologyCount, ref1 = seq.length - Count.DefaultHomologyCount; j <= ref1; i = j += 1) {
      str = currentSeq.slice(i, +(i + Count.DefaultHomologyCount - 1) + 1 || 9e9);
      upperInd = currentSeq.indexOf(str, i + 1);
      lowerInd = currentSeq.slice(0, +(i + Count.DefaultHomologyCount - 2) + 1 || 9e9).indexOf(str);
      if ((lowerInd !== -1) || (upperInd !== -1)) {
        if (ind) {
          inds.push({
            start: i,
            str: str
          });
        } else {
          ++numRepeats;
        }
      }
    }
    if (ind) {
      return inds;
    } else {
      return numRepeats;
    }
  };

  Count.deaminationSites = function(seq, ind) {
    return Count.countOrInd(seq, symbols.DeaminationSites, ind);
  };

  Count.alkylationSites = function(seq, ind) {
    return Count.countOrInd(seq, symbols.AlkylationSites, ind);
  };

  Count.oxidationSites = function(seq, ind) {
    return Count.countOrInd(seq, symbols.OxidationSites, ind);
  };

  Count.miscSites = function(seq, ind) {
    return Count.countOrInd(seq, symbols.MiscSites, ind);
  };

  Count.hairpinSites = function(seq, ind) {
    var j, len, match, reg, res, sites;
    sites = symbols.HairpinSites;
    if (ind) {
      res = {};
      for (j = 0, len = sites.length; j < len; j++) {
        reg = sites[j];
        res[reg] = ((function() {
          var results;
          results = [];
          while ((match = (reg.exec(seq)) != null)) {
            results.push(match.index);
          }
          return results;
        })());
      }
      return res;
    } else {
      return sites.map(function(reg) {
        return (seq.match(reg) || []).length;
      }).sum();
    }
  };

  Count.insertionSequences = function(seq, ind) {
    return Count.countOrInd(seq, symbols.InsertionSequences, ind);
  };

  Count.RFC10Sites = function(seq, ind) {
    return Count.countOrInd(seq, symbols.RFC10Sites, ind);
  };

  Count.ModifyWeightsOnAdvancedOptions = function(weights, opt, val) {
    switch (opt) {
      case 'RFC10':
        weights['RFC10'] = val ? symbols.FunctionWeights['RFC10'].weight : 0;
        return weights;
      case 'Rate Limiting Codons':
        weights['Rate Limiting Codons'] = val ? 0 : symbols.FunctionWeights['Rate Limiting Codons'].weight;
        return weights;
      default:
        return weights;
    }
  };

  Count.AllFuns = (function() {
    var ref, results;
    ref = symbols.FunctionWeights;
    results = [];
    for (k in ref) {
      v = ref[k];
      f = Count[v.func];
      results.push({
        func: v.needsCurSeq ? f : (function(f) {
          return function(seq, constrSeq, ind) {
            return f(seq, ind);
          };
        })(f),
        weight: v.weight,
        name: v.func,
        title: k,
        inFrame: v.inFrame
      });
    }
    return results;
  })();

  Count.SumAllWeights = function(seq, constrSeq, weights) {
    return Count.AllFuns.map((weights ? function(f) {
      return (f.func(seq, constrSeq)) * weights[f.title];
    } : function(f) {
      return (f.func(seq, constrSeq)) * f.weight;
    })).sum();
  };

  Count.AllCounts = function(seq, constrSeq) {
    var cur, el, j, len, ref, res, sum;
    if (constrSeq == null) {
      constrSeq = seq;
    }
    res = {};
    sum = 0;
    ref = Count.AllFunsCleaned;
    for (j = 0, len = ref.length; j < len; j++) {
      el = ref[j];
      cur = el.func(seq, constrSeq);
      sum += cur * el.weight;
      res[el.name] = cur;
    }
    res.mutability_score = sum;
    return res;
  };

  Count.MutabilityScore = function(seq, constrSeq, arg) {
    var adv, ref, ref1, ref2, ref3, res, singleWeight, weights;
    if (constrSeq == null) {
      constrSeq = null;
    }
    ref = arg != null ? arg : {}, singleWeight = (ref1 = ref.singleWeight) != null ? ref1 : null, weights = (ref2 = ref.weights) != null ? ref2 : null, adv = (ref3 = ref.adv) != null ? ref3 : null;
    seq = seq.toUpperCase();
    constrSeq = seq.toUpperCase();
    if (singleWeight) {
      return singleWeight(seq, constrSeq);
    } else {
      if (weights && (adv != null)) {
        for (k in adv) {
          v = adv[k];
          weights = Count.ModifyWeightsOnAdvancedOptions(weights, k, v);
        }
      }
      res = Count.SumAllWeights(seq, constrSeq, weights);
      if (adv != null ? adv['Evolution'] : void 0) {
        return res * -1;
      } else {
        return res;
      }
    }
  };

  Count.HotspotIndices = function(seq, constrSeq) {
    seq = seq.toUpperCase();
    constrSeq = constrSeq.toUpperCase();
    return Count.AllFuns.map(function(f) {
      return {
        indices: f.func(seq, constrSeq, true),
        title: f.title
      };
    });
  };

  return Count;

})();

DNASequence = (function(superClass) {
  extend(DNASequence, superClass);

  function DNASequence() {
    return DNASequence.__super__.constructor.apply(this, arguments);
  }

  DNASequence.ValidIUPACSyms = symbols.DNAIUPAC;

  DNASequence.CodonAminoMap = utils.ConvoluteKeysValues(symbols.DNACodonAminoMap);

  DNASequence.TransformSyms = symbols.DNATransformSyms;

  DNASequence.StartCodons = symbols.StartCodons;

  DNASequence.StopCodons = symbols.StopCodons;

  DNASequence.FixEndOpts = {
    beg: {
      len: 3,
      text: DNASequence.StartCodons
    },
    end: {
      len: 3,
      text: DNASequence.StopCodons
    },
    doThrow: true
  };

  DNASequence.prototype.check = function(seq) {
    if (seq.length % 3) {
      this.err("not multiple of 3: " + seq.length);
    }
    this.constructor.StopCodons.forEach((function(_this) {
      return function(codon) {
        var ind;
        ind = seq.indexOf(codon);
        if (ind > 0 && ind < seq.length - 3 && ind % 3 === 0) {
          return _this.err("Premature stop codon " + codon + " at index " + ind);
        }
      };
    })(this));
    return seq;
  };

  DNASequence.prototype.toAminoSeqFromSplit = function(splitSeq) {
    return new AminoAcidSequence(splitSeq.map((function(_this) {
      return function(codon) {
        return _this.constructor.CodonAminoMap[codon] || _this.err("codon " + codon + " is invalid");
      };
    })(this)));
  };

  DNASequence.prototype.toAminoSeq = function() {
    return this.toAminoSeqFromSplit(Count.splitCodons(this.seq));
  };

  return DNASequence;

})(Sequence);

module.exports = {
  SequenceError: SequenceError,
  AminoAcidSequence: AminoAcidSequence,
  Count: Count,
  DNASequence: DNASequence
};
