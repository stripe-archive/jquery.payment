{spawn} = require 'child_process'

task 'build', 'Build lib/ from src/', ->
  spawn 'coffee', ['-c', '-o', 'lib', 'src'], stdio: 'inherit'

task 'watch', 'Watch src/ for changes', ->
  spawn 'coffee', ['-w', '-c', '-o', 'lib', 'src'], stdio: 'inherit'

task 'test', 'Run tests', ->
  spawn 'mocha', ['--compilers', 'coffee:coffee-script/register'], stdio: 'inherit'
