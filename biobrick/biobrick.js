var $, DumpStream, XmlStream, _, fs, getPartSeq, getTablesPage, http, managementRegex, replaceTable, retryTime, scrapePartsFromPgroupPage, transformTableManagementToPartsDb;

fs = require('fs');

http = require('http');

_ = require('lodash');

DumpStream = require('dump-stream');

$ = require('cheerio');

XmlStream = require('xml-stream');

managementRegex = /\/management\/table\.cgi\?table_name=/;

replaceTable = "/partsdb/pgroup.cgi?pgroup=";

getTablesPage = function(cb) {
  return http.get("http://parts.igem.org/cgi/management/table.cgi", function(resp) {
    var s;
    s = new DumpStream;
    return resp.pipe(s).on('finish', function() {
      return cb($('tr td a', s.dump()).map(function(ind, el) {
        return el.attribs.href;
      }).get().filter(function(el) {
        return el.match(managementRegex);
      }));
    });
  });
};

transformTableManagementToPartsDb = function(url) {
  return url.replace(managementRegex, replaceTable) + "&show=1";
};

scrapePartsFromPgroupPage = function(urls, cb, arr) {
  if (urls.length <= 0) {
    return;
  }
  arr = _.uniq(arr.sort()) || [];
  return http.get(urls[0], function(resp) {
    var s;
    s = new DumpStream;
    return resp.pipe(s).on('finish', function() {
      var thisArr;
      thisArr = (arr || []).concat($('a.part_link', s.dump()).map(function(ind, el) {
        return el.children;
      }).get().map(function(el) {
        return el.data;
      }));
      return setTimeout((function() {
        if (urls.length === 1) {
          return cb(thisArr);
        } else {
          return scrapePartsFromPgroupPage(urls.slice(1), cb, thisArr);
        }
      }), 1000);
    });
  });
};

retryTime = 200;

getPartSeq = function(name, cb) {
  return http.get("http://parts.igem.org/cgi/xml/part.cgi?part=" + name, function(resp) {
    var partStream;
    partStream = new XmlStream(resp);
    partStream.collect('seq_data');
    partStream.on('endElement: sequences', function(seqArr) {
      return cb(seqArr['seq_data'].map(function(seq) {
        return seq.toUpperCase().replace(/\s/g, "");
      }));
    });
    return partStream.on('error', function(err) {
      return console.error("xml parse error " + err.message + " from part " + name + ", not retrying");
    });
  }).on('error', function(err) {
    console.error("connection error " + err.message + " from part " + name + ", retrying in " + retryTime + " ms");
    return setTimeout((function() {
      return getPartSeq(name, cb);
    }), retryTime);
  });
};

module.exports = {
  getTablesPage: getTablesPage,
  transformTableManagementToPartsDb: transformTableManagementToPartsDb,
  scrapePartsFromPgroupPage: scrapePartsFromPgroupPage,
  getPartSeq: getPartSeq
};
