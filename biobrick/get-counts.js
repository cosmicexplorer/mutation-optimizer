var AminoAcidSequence, Count, DNASequence, fs, ref, stream;

fs = require('fs');

stream = require('stream');

ref = require('../lib/mutation-optimizer'), Count = ref.Count, AminoAcidSequence = ref.AminoAcidSequence, DNASequence = ref.DNASequence;

fs.readFile('../biobrick/out-file-seqs.json', function(err, data) {
  var aminoCheckParts, aminoCheckStream, dnaCheckParts, dnaCheckStream, firstAminoPart, firstDNAPart, makeLogFromPart, seqKeys, seqs;
  if (err) {
    throw err;
  }
  seqs = JSON.parse(data.toString());
  seqKeys = Object.keys(seqs);
  makeLogFromPart = function(part) {
    var seq;
    seq = seqs[part][0];
    return {
      rateLimitingCodons: Count.rateLimitingCodons(seq),
      antiShineDelgarno: Count.antiShineDelgarno(seq),
      ttDimerCount: Count.ttDimerCount(seq),
      otherPyrDimerCount: Count.otherPyrDimerCount(seq),
      weightedPyrDimerCount: Count.weightedPyrDimerCount(seq),
      methylationSites: Count.methylationSites(seq),
      repeatRuns: Count.repeatRuns(seq),
      deaminationSites: Count.deaminationSites(seq),
      alkylationSites: Count.alkylationSites(seq),
      oxidationSites: Count.oxidationSites(seq),
      miscSites: Count.miscSites(seq),
      hairpinSites: Count.hairpinSites(seq),
      insertionSequences: Count.insertionSequences(seq)
    };
  };
  aminoCheckStream = new stream.PassThrough;
  aminoCheckStream.pipe(fs.createWriteStream('out-counts-amino.json'));
  dnaCheckStream = new stream.PassThrough;
  dnaCheckStream.pipe(fs.createWriteStream('out-counts-dna.json'));
  aminoCheckStream.write('{\n');
  aminoCheckParts = seqKeys.filter(function(part) {
    var error;
    try {
      (new DNASequence(seqs[part][0])).toAminoSeq().clean();
      return true;
    } catch (error) {
      return false;
    }
  });
  firstAminoPart = aminoCheckParts[0];
  aminoCheckStream.write("\"" + firstAminoPart + "\": " + (JSON.stringify(makeLogFromPart(firstAminoPart))) + "\n");
  aminoCheckParts.slice(1).forEach(function(part) {
    return aminoCheckStream.write(",\"" + part + "\": " + (JSON.stringify(makeLogFromPart(part))) + "\n");
  });
  aminoCheckStream.write('}\n');
  dnaCheckStream.write('{\n');
  dnaCheckParts = seqKeys.filter(function(part) {
    var error;
    try {
      (new DNASequence(seqs[part][0])).clean();
      return true;
    } catch (error) {
      return false;
    }
  });
  firstDNAPart = dnaCheckParts[0];
  dnaCheckStream.write("\"" + firstDNAPart + "\": " + (JSON.stringify(makeLogFromPart(firstDNAPart))) + "\n");
  dnaCheckParts.slice(1).forEach(function(part) {
    return dnaCheckStream.write(",\"" + part + "\": " + (JSON.stringify(makeLogFromPart(part))) + "\n");
  });
  return dnaCheckStream.write('}\n');
});
