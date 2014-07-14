{spawn} = require 'child_process'
path    = require 'path'

binPath = (bin) -> path.resolve(__dirname, "./node_modules/.bin/#{bin}")

runExternal = (cmd, args) ->
  child = spawn(binPath(cmd), args, stdio: 'inherit')
  child.on('error', console.error)
  child.on('close', process.exit)

task 'build', 'Build lib/ from src/', ->
  runExternal 'coffee', ['-c', '-o', 'lib', 'src']

task 'watch', 'Watch src/ for changes', ->
  runExternal 'coffee', ['-w', '-c', '-o', 'lib', 'src']

task 'test', 'Run tests', ->
  runExternal 'mocha', ['--compilers', 'coffee:coffee-script/register']
