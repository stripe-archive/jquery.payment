{spawn} = require 'child_process'
path    = require 'path'

binPath = (bin) -> path.resolve(__dirname, "./node_modules/.bin/#{bin}")

runExternal = (cmd, args, callback = process.exit) ->
  child = spawn(binPath(cmd), args, stdio: 'inherit')
  child.on('error', console.error)
  child.on('close', callback)

runSequential = (cmds, status = 0) ->
  process.exit status if status or !cmds.length
  cmd = cmds.shift()
  cmd.push (status) -> runSequential cmds, status
  runExternal.apply null, cmd

task 'build', 'Build lib/ from src/', ->
  runExternal 'coffee',
    ['-c', '-o', 'lib', 'src'],
    -> invoke 'minify'

task 'minify', 'Minify lib/', ->
  runExternal 'uglifyjs', [
    'lib/jquery.payment.js',
    '--mangle',
    '--compress',
    '--output',
    'lib/jquery.payment.min.js'
  ]

task 'watch', 'Watch src/ for changes', ->
  runExternal 'coffee', ['-w', '-c', '-o', 'lib', 'src']

task 'test', 'Run tests', ->
  runSequential [
    ['mocha', ['--compilers', 'coffee:coffee-script/register', 'test/jquery.coffee']]
    ['mocha', ['--compilers', 'coffee:coffee-script/register', 'test/zepto.coffee']]
  ]
