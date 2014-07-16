assert = require('assert')
window = require('jsdom').jsdom().createWindow()
$      = require('jquery')(window)
global.jQuery = $
global.window = window
global.document = window.document

require('../src/jquery.payment')

describe 'jquery.payment', ->
  describe 'Validating a card number', ->
    it 'should fail if empty', ->
      topic = $.payment.validateCardNumber ''
      assert.equal topic, false

    it 'should fail if is a bunch of spaces', ->
      topic = $.payment.validateCardNumber '                 '
      assert.equal topic, false

    it 'should success if is valid', ->
      topic = $.payment.validateCardNumber '4242424242424242'
      assert.equal topic, true

    it 'that has dashes in it but is valid', ->
      topic = $.payment.validateCardNumber '4242-4242-4242-4242'
      assert.equal topic, true

    it 'should succeed if it has spaces in it but is valid', ->
      topic = $.payment.validateCardNumber '4242 4242 4242 4242'
      assert.equal topic, true

    it 'that does not pass the luhn checker', ->
      topic = $.payment.validateCardNumber '4242424242424241'
      assert.equal topic, false

    it 'should fail if is more than 16 digits', ->
      topic = $.payment.validateCardNumber '42424242424242424'
      assert.equal topic, false

    it 'should fail if is less than 10 digits', ->
      topic = $.payment.validateCardNumber '424242424'
      assert.equal topic, false

    it 'should fail with non-digits', ->
      topic = $.payment.validateCardNumber '4242424e42424241'
      assert.equal topic, false

    it 'should validate for all card types', ->
      assert($.payment.validateCardNumber('4917300800000000'), 'visaelectron')

      assert($.payment.validateCardNumber('6759649826438453'), 'maestro')

      assert($.payment.validateCardNumber('630495060000000000'), 'laser')
      assert($.payment.validateCardNumber('630490017740292441'), 'laser')

      assert($.payment.validateCardNumber('4111111111111111'), 'visa')
      assert($.payment.validateCardNumber('4012888888881881'), 'visa')
      assert($.payment.validateCardNumber('4222222222222'), 'visa')
      assert($.payment.validateCardNumber('4462030000000000'), 'visa')
      assert($.payment.validateCardNumber('4484070000000000'), 'visa')

      assert($.payment.validateCardNumber('5555555555554444'), 'mastercard')
      assert($.payment.validateCardNumber('5454545454545454'), 'mastercard')

      assert($.payment.validateCardNumber('378282246310005'), 'amex')
      assert($.payment.validateCardNumber('371449635398431'), 'amex')
      assert($.payment.validateCardNumber('378734493671000'), 'amex')

      assert($.payment.validateCardNumber('30569309025904'), 'dinersclub')
      assert($.payment.validateCardNumber('38520000023237'), 'dinersclub')
      assert($.payment.validateCardNumber('36700102000000'), 'dinersclub')
      assert($.payment.validateCardNumber('36148900647913'), 'dinersclub')

      assert($.payment.validateCardNumber('6011111111111117'), 'discover')
      assert($.payment.validateCardNumber('6011000990139424'), 'discover')

      assert($.payment.validateCardNumber('6271136264806203568'), 'unionpay')
      assert($.payment.validateCardNumber('6236265930072952775'), 'unionpay')
      assert($.payment.validateCardNumber('6204679475679144515'), 'unionpay')
      assert($.payment.validateCardNumber('6216657720782466507'), 'unionpay')

      assert($.payment.validateCardNumber('3530111333300000'), 'jcb')
      assert($.payment.validateCardNumber('3566002020360505'), 'jcb')

  describe 'Validating a CVC', ->
    it 'should fail if is empty', ->
      topic = $.payment.validateCardCVC ''
      assert.equal topic, false

    it 'should pass if is valid', ->
      topic = $.payment.validateCardCVC '123'
      assert.equal topic, true

    it 'should fail with non-digits', ->
      topic = $.payment.validateCardNumber '12e'
      assert.equal topic, false

    it 'should fail with less than 3 digits', ->
      topic = $.payment.validateCardNumber '12'
      assert.equal topic, false

    it 'should fail with more than 4 digits', ->
      topic = $.payment.validateCardNumber '12345'
      assert.equal topic, false

  describe 'Validating an expiration date', ->
    it 'should fail expires is before the current year', ->
      currentTime = new Date()
      topic = $.payment.validateCardExpiry currentTime.getMonth() + 1, currentTime.getFullYear() - 1
      assert.equal topic, false

    it 'that expires in the current year but before current month', ->
      currentTime = new Date()
      topic = $.payment.validateCardExpiry currentTime.getMonth(), currentTime.getFullYear()
      assert.equal topic, false

    it 'that has an invalid month', ->
      currentTime = new Date()
      topic = $.payment.validateCardExpiry 13, currentTime.getFullYear()
      assert.equal topic, false

    it 'that is this year and month', ->
      currentTime = new Date()
      topic = $.payment.validateCardExpiry currentTime.getMonth() + 1, currentTime.getFullYear()
      assert.equal topic, true

    it 'that is just after this month', ->
      # Remember - months start with 0 in JavaScript!
      currentTime = new Date()
      topic = $.payment.validateCardExpiry currentTime.getMonth() + 1, currentTime.getFullYear()
      assert.equal topic, true

    it 'that is after this year', ->
      currentTime = new Date()
      topic = $.payment.validateCardExpiry currentTime.getMonth() + 1, currentTime.getFullYear() + 1
      assert.equal topic, true

    it 'that has string numbers', ->
      currentTime = new Date()
      currentTime.setFullYear(currentTime.getFullYear() + 1, currentTime.getMonth() + 2)
      topic = $.payment.validateCardExpiry currentTime.getMonth() + '', currentTime.getFullYear() + ''
      assert.equal topic, true

    it 'that has non-numbers', ->
      topic = $.payment.validateCardExpiry 'h12', '3300'
      assert.equal topic, false

    it 'should fail if year or month is NaN', ->
      topic = $.payment.validateCardExpiry '12', NaN
      assert.equal topic, false

    it 'should support year shorthand', ->
      assert.equal $.payment.validateCardExpiry('05', '20'), true

  describe 'Validating a CVC number', ->
    it 'should validate a three digit number with no card type', ->
      topic = $.payment.validateCardCVC('123')
      assert.equal topic, true

    it 'should validate a three digit number with card type amex', ->
      topic = $.payment.validateCardCVC('123', 'amex')
      assert.equal topic, true

    it 'should validate a three digit number with card type other than amex', ->
      topic = $.payment.validateCardCVC('123', 'visa')
      assert.equal topic, true

    it 'should not validate a four digit number with a card type other than amex', ->
      topic = $.payment.validateCardCVC('1234', 'visa')
      assert.equal topic, false

    it 'should validate a four digit number with card type amex', ->
      topic = $.payment.validateCardCVC('1234', 'amex')
      assert.equal topic, true

    it 'should not validate a number larger than 4 digits', ->
      topic = $.payment.validateCardCVC('12344')
      assert.equal topic, false

  describe 'Parsing an expiry value', ->
    it 'should parse string expiry', ->
      topic = $.payment.cardExpiryVal('03 / 2025')
      assert.deepEqual topic, month: 3, year: 2025

    it 'should support shorthand year', ->
      topic = $.payment.cardExpiryVal('05/04')
      assert.deepEqual topic, month: 5, year: 2004

    it 'should return NaN when it cannot parse', ->
      topic = $.payment.cardExpiryVal('05/dd')
      assert isNaN(topic.year)

  describe 'Getting a card type', ->
    it 'should return Visa that begins with 40', ->
      topic = $.payment.cardType '4012121212121212'
      assert.equal topic, 'visa'

    it 'that begins with 5 should return MasterCard', ->
      topic = $.payment.cardType '5555555555554444'
      assert.equal topic, 'mastercard'

    it 'that begins with 34 should return American Express', ->
      topic = $.payment.cardType '3412121212121212'
      assert.equal topic, 'amex'

    it 'that is not numbers should return null', ->
      topic = $.payment.cardType 'aoeu'
      assert.equal topic, null

    it 'that has unrecognized beginning numbers should return null', ->
      topic = $.payment.cardType 'aoeu'
      assert.equal topic, null

    it 'should return correct type for all test numbers', ->
      assert.equal($.payment.cardType('4917300800000000'), 'visaelectron')

      assert.equal($.payment.cardType('6759649826438453'), 'maestro')

      assert.equal($.payment.cardType('630495060000000000'), 'laser')
      assert.equal($.payment.cardType('630490017740292441'), 'laser')

      assert.equal($.payment.cardType('4111111111111111'), 'visa')
      assert.equal($.payment.cardType('4012888888881881'), 'visa')
      assert.equal($.payment.cardType('4222222222222'), 'visa')
      assert.equal($.payment.cardType('4462030000000000'), 'visa')
      assert.equal($.payment.cardType('4484070000000000'), 'visa')

      assert.equal($.payment.cardType('5555555555554444'), 'mastercard')
      assert.equal($.payment.cardType('5454545454545454'), 'mastercard')

      assert.equal($.payment.cardType('378282246310005'), 'amex')
      assert.equal($.payment.cardType('371449635398431'), 'amex')
      assert.equal($.payment.cardType('378734493671000'), 'amex')

      assert.equal($.payment.cardType('30569309025904'), 'dinersclub')
      assert.equal($.payment.cardType('38520000023237'), 'dinersclub')
      assert.equal($.payment.cardType('36700102000000'), 'dinersclub')
      assert.equal($.payment.cardType('36148900647913'), 'dinersclub')

      assert.equal($.payment.cardType('6011111111111117'), 'discover')
      assert.equal($.payment.cardType('6011000990139424'), 'discover')

      assert.equal($.payment.cardType('6271136264806203568'), 'unionpay')
      assert.equal($.payment.cardType('6236265930072952775'), 'unionpay')
      assert.equal($.payment.cardType('6204679475679144515'), 'unionpay')
      assert.equal($.payment.cardType('6216657720782466507'), 'unionpay')

      assert.equal($.payment.cardType('3530111333300000'), 'jcb')
      assert.equal($.payment.cardType('3566002020360505'), 'jcb')

  describe 'formatCardNumber', ->
    it 'should format cc number correctly', ->
      $number = $('<input type=text>').payment('formatCardNumber')
      $number.val('4242')

      e = $.Event('keypress')
      e.which = 52 # '4'
      $number.trigger(e)

      assert.equal $number.val(), '4242 4'

    it 'should trigger cardNumberFormatted event', (done) ->

      $number = $('<input type=text>').payment('formatCardNumber')
      $number.on 'payment.cardNumberFormatted', ->
        assert.equal $number.val(), '4242 4'
        done()

      $number.val('4242')

      e = $.Event('keypress')
      e.which = 52 # '4'
      $number.trigger(e)

  describe 'formatCardExpiry', ->
    it 'should format month shorthand correctly', ->
      $expiry = $('<input type=text>').payment('formatCardExpiry')

      e = $.Event('keypress')
      e.which = 52 # '4'
      $expiry.trigger(e)

      assert.equal $expiry.val(), '04 / '

    it 'should format forward slash shorthand correctly', ->
      $expiry = $('<input type=text>').payment('formatCardExpiry')
      $expiry.val('1')

      e = $.Event('keypress')
      e.which = 47 # '/'
      $expiry.trigger(e)

      assert.equal $expiry.val(), '01 / '

    it 'should only allow numbers', ->
      $expiry = $('<input type=text>').payment('formatCardExpiry')
      $expiry.val('1')

      e = $.Event('keypress')
      e.which = 100 # 'd'
      $expiry.trigger(e)

      assert.equal $expiry.val(), '1'

    it 'should trigger cardExpiryFormatted event (month)', (done) ->

      $expiry = $('<input type=text>').payment('formatCardExpiry')

      $expiry.on 'payment.cardExpiryFormatted', ->
        assert.equal $expiry.val(), '04 / '
        done()

      e = $.Event('keypress')
      e.which = 52 # '4'
      $expiry.trigger(e)

    it 'should trigger cardExpiryFormatted event (slash)', (done) ->

      $expiry = $('<input type=text>').payment('formatCardExpiry')
      $expiry.val('1')

      $expiry.on 'payment.cardExpiryFormatted', ->
        assert.equal $expiry.val(), '01 / '
        done()

      e = $.Event('keypress')
      e.which = 47 # '/'
      $expiry.trigger(e)
