window = require('jsdom').jsdom().parentWindow;
global.window = window
global.document = window.document
global.getComputedStyle = window.getComputedStyle
global.$ = require('zeptojs')
window.$ = global.$

require('../src/jquery.payment')
require('./specs')
