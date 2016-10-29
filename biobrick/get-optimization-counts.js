var AminoAcidSequence, Count, DNASequence, PARALLEL_JOBS, async, begin, end, fs, ref, ref1, ref2, ref3, stream;

fs = require('fs');

stream = require('stream');

async = require('async');

PARALLEL_JOBS = 10;

ref = process.argv.slice(2), begin = (ref1 = ref[0]) != null ? ref1 : 0, end = (ref2 = ref[1]) != null ? ref2 : -1;

ref3 = require('../lib/mutation-optimizer'), Count = ref3.Count, AminoAcidSequence = ref3.AminoAcidSequence, DNASequence = ref3.DNASequence;

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
    return (new DNASequence(seq)).toAminoSeq().minimizeAllMutations(seq);
  };
  aminoCheckStream = new stream.PassThrough;
  aminoCheckStream.pipe(fs.createWriteStream('out-opt-counts-amino.json'));
  dnaCheckStream = new stream.PassThrough;
  dnaCheckStream.pipe(fs.createWriteStream('out-opt-counts-dna.json'));
  aminoCheckStream.write('{\n');
  console.log("wow");
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
  aminoCheckParts.slice(1).slice(begin, +end + 1 || 9e9).forEach(function(part) {
    var error;
    console.log("amino start");
    try {
      aminoCheckStream.write(",\"" + part + "\": " + (JSON.stringify(makeLogFromPart(part))) + "\n");
      return console.log("amino: " + part);
    } catch (error) {
      err = error;
      console.log(err.stack);
      return console.log([err.message, err.type]);
    }
  });
  aminoCheckStream.end('}\n');
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
  dnaCheckParts.slice(1).slice(begin, +end + 1 || 9e9).forEach(function(part) {
    var error;
    console.log("amino start");
    try {
      dnaCheckStream.write(",\"" + part + "\": " + (JSON.stringify(makeLogFromPart(part))) + "\n");
      return console.log("dna: " + part);
    } catch (error) {
      err = error;
      console.log(err.stack);
      return console.log([err.message, err.type]);
    }
  });
  return dnaCheckStream.end('}\n');
});
