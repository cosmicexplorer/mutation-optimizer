fs = require 'fs'
http = require 'http'

_ = require 'lodash'
DumpStream = require 'dump-stream'
$ = require 'cheerio'
XmlStream = require 'xml-stream'

managementRegex = /\/management\/table\.cgi\?table_name=/
replaceTable = "/partsdb/pgroup.cgi?pgroup="

# pass in function to operate on array of results
getTablesPage = (cb) ->
  http.get "http://parts.igem.org/cgi/management/table.cgi", (resp) ->
    s = new DumpStream
    resp.pipe(s).on 'finish', -> cb $('tr td a', s.dump()).map((ind, el) ->
      el.attribs.href).get().filter((el) -> el.match managementRegex)

# once given table in management, transform to useful table
transformTableManagementToPartsDb = (url) ->
  url.replace(managementRegex, replaceTable) + "&show=1"

# concatenate async calls
scrapePartsFromPgroupPage = (urls, cb, arr) ->
  return if urls.length <= 0
  arr = _.uniq(arr.sort()) or []
  # console.log urls.length
  # console.log arr.length
  # fs.writeFileSync 'out-file', JSON.stringify arr
  http.get urls[0], (resp) ->
    s = new DumpStream
    resp.pipe(s).on 'finish', ->
      thisArr = (arr or []).concat $('a.part_link', s.dump()).map((ind, el) ->
        el.children).get().map (el) -> el.data
      # wish we had real pattern matching here, but oh well
      # setTimeout is nice for avoiding throttling, but also because it clears
      # the call stack so we can do this recursive asynchrony thing
      setTimeout((->
        if urls.length is 1
          cb thisArr
        else
          scrapePartsFromPgroupPage urls[1..], cb, thisArr),
        1000)

# getTablesPage (urls) ->
#   scrapePartsFromPgroupPage urls.map(transformTableManagementToPartsDb),
#     console.log

retryTime = 200

getPartSeq = (name, cb) ->
  http.get("http://parts.igem.org/cgi/xml/part.cgi?part=#{name}", (resp) ->
    partStream = new XmlStream resp
    partStream.collect 'seq_data'
    partStream.on 'endElement: sequences', (seqArr) ->
      cb seqArr['seq_data'].map (seq) -> seq.toUpperCase().replace /\s/g, ""
    # discard ones with invalid xml
    partStream.on 'error', (err) ->
      console.error "xml parse error #{err.message} from part #{name},
      not retrying").on 'error', (err) ->
        console.error "connection error #{err.message} from part #{name},
        retrying in #{retryTime} ms"
        setTimeout (-> getPartSeq name, cb), retryTime

# name = 'BBa_B0034'
# getPartSeq name, (seq) ->
#   console.log {name: name, seq: seq}

module.exports =
  getTablesPage: getTablesPage
  transformTableManagementToPartsDb: transformTableManagementToPartsDb
  scrapePartsFromPgroupPage: scrapePartsFromPgroupPage
  getPartSeq: getPartSeq
