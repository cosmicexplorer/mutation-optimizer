{spawn} = require('child_process')

splitArrayByIndex = (index, arr) ->
  left: arr[..(index - 1)]
  right: arr[(index + 1)..]

splitArrayByElement = (el, arr) ->
  ind = arr.indexOf el
  switch ind
    when -1 then [arr]
    else
      {left, right} = splitArrayByIndex ind, arr
      [left].concat splitArrayByElement el, right

chainProcessStdio = (argvs) ->
  curArgv = argvs[0]
  curProc = spawn curArgv[0], curArgv[1..]
  curProc.stdout.pipe switch argvs.length
    when 1 then process.stdout
    else chainProcessStdio argvs[1..]
  curProc.stderr.pipe process.stderr
  # this is the magic part
  curProc.on 'exit', (code) -> process.exit code if code
  curProc.stdin

commandPipeline = chainProcessStdio splitArrayByElement '|', process.argv[2..]

process.stdin.pipe commandPipeline if process.env.LISTEN
