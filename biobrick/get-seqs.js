var TASK_LIM, async, biobrick, counter, fs, stream;

fs = require('fs');

stream = require('stream');

async = require('async');

biobrick = require('./biobrick');

TASK_LIM = 50;

counter = 0;

fs.readFile('out-file-cleaned', function(err, data) {
  var arrLen, downloadPart, inStream, partNums, queue;
  if (err) {
    throw err;
  }
  partNums = JSON.parse(data.toString());
  arrLen = partNums.length;
  inStream = new stream.PassThrough;
  downloadPart = function(part, cb, noComma) {
    return biobrick.getPartSeq(part, function(seq) {
      var line, pct;
      line = "\"" + part + "\": " + (JSON.stringify(seq));
      if (!noComma) {
        line = "," + line;
      }
      line += "\n";
      pct = Math.round(++counter / arrLen * 100 * 100);
      pct = pct / 100;
      console.log("about " + counter + " / " + arrLen + " (" + pct + "%) downloaded");
      inStream.write(line);
      return cb();
    });
  };
  queue = async.queue(downloadPart);
  inStream.pipe(fs.createWriteStream('out-file-seqs.json'));
  inStream.write('{\n');
  queue.empty = function() {
    inStream.write('}');
    return console.log("DONE!");
  };
  queue.concurrency = TASK_LIM;
  return downloadPart(partNums[0], (function() {
    return queue.push(partNums.slice(1));
  }), true);
});
