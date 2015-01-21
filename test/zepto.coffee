window = require('jsdom').jsdom().createWindow()
global.window = window
global.document = window.document
global.getComputedStyle = window.getComputedStyle
global.$ = require('zeptojs')

require('../src/jquery.payment')
require('./specs')
