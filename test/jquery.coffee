window = require('jsdom').jsdom().createWindow()
global.$ = require('jquery')(window)
global.window = window
global.document = window.document

require('../src/jquery.payment')
require('./specs')
