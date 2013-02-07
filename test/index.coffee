assert = require('assert')
$      = require('jquery')
global.jQuery = $

require('../src/jquery.payment')

describe 'jquery.payment', ->
  describe 'Validating a card number', ->
    it 'should fail if empty', ->
      topic = $.validateCardNumber ''
      assert.equal topic, false

    it 'should fail if is a bunch of spaces', ->
      topic = $.validateCardNumber '                 '
      assert.equal topic, false

    it 'should success if is valid', ->
      topic = $.validateCardNumber '4242424242424242'
      assert.equal topic, true

    it 'that has dashes in it but is valid', ->
      topic = $.validateCardNumber '4242-4242-4242-4242'
      assert.equal topic, true

    it 'should succeed if it has spaces in it but is valid', ->
      topic = $.validateCardNumber '4242 4242 4242 4242'
      assert.equal topic, true

    it 'that does not pass the luhn checker', ->
      topic = $.validateCardNumber '4242424242424241'
      assert.equal topic, false

    it 'should fail if is more than 16 digits', ->
      topic = $.validateCardNumber '42424242424242424'
      assert.equal topic, false

    it 'should fail if is less than 10 digits', ->
      topic = $.validateCardNumber '424242424'
      assert.equal topic, false

    it 'should fail with non-digits', ->
      topic = $.validateCardNumber '4242424e42424241'
      assert.equal topic, false

    it 'should validate for all card types', ->
      assert($.validateCardNumber('378282246310005'), 'amex')
      assert($.validateCardNumber('371449635398431'), 'amex')
      assert($.validateCardNumber('378734493671000'), 'amex')

      assert($.validateCardNumber('30569309025904'), 'dinersclub')
      assert($.validateCardNumber('38520000023237'), 'dinersclub')

      assert($.validateCardNumber('6011111111111117'), 'discover')
      assert($.validateCardNumber('6011000990139424'), 'discover')

      assert($.validateCardNumber('3530111333300000'), 'jcb')
      assert($.validateCardNumber('3566002020360505'), 'jcb')

      assert($.validateCardNumber('5555555555554444'), 'mastercard')

      assert($.validateCardNumber('4111111111111111'), 'visa')
      assert($.validateCardNumber('4012888888881881'), 'visa')
      assert($.validateCardNumber('4222222222222'), 'visa')

      assert($.validateCardNumber('6759649826438453'), 'maestro')

      assert($.validateCardNumber('6271136264806203568'), 'unionpay')
      assert($.validateCardNumber('6236265930072952775'), 'unionpay')
      assert($.validateCardNumber('6204679475679144515'), 'unionpay')
      assert($.validateCardNumber('6216657720782466507'), 'unionpay')

  describe 'Validating a CVC', ->
    it 'should fail if is empty', ->
      topic = $.validateCardCVC ''
      assert.equal topic, false

    it 'should pass if is valid', ->
      topic = $.validateCardCVC '123'
      assert.equal topic, true

    it 'should fail with non-digits', ->
      topic = $.validateCardNumber '12e'
      assert.equal topic, false

    it 'should fail with less than 3 digits', ->
      topic = $.validateCardNumber '12'
      assert.equal topic, false

    it 'should fail with more than 4 digits', ->
      topic = $.validateCardNumber '12345'
      assert.equal topic, false

  describe 'Validating an expiration date', ->
    it 'should fail expires is before the current year', ->
      currentTime = new Date()
      topic = $.validateCardExpiry currentTime.getMonth() + 1, currentTime.getFullYear() - 1
      assert.equal topic, false

    it 'that expires in the current year but before current month', ->
      currentTime = new Date()
      topic = $.validateCardExpiry currentTime.getMonth(), currentTime.getFullYear()
      assert.equal topic, false

    it 'that has an invalid month', ->
      currentTime = new Date()
      topic = $.validateCardExpiry 13, currentTime.getFullYear()
      assert.equal topic, false

    it 'that is this year and month', ->
      currentTime = new Date()
      topic = $.validateCardExpiry currentTime.getMonth() + 1, currentTime.getFullYear()
      assert.equal topic, true

    it 'that is just after this month', ->
      # Remember - months start with 0 in JavaScript!
      currentTime = new Date()
      topic = $.validateCardExpiry currentTime.getMonth() + 1, currentTime.getFullYear()
      assert.equal topic, true

    it 'that is after this year', ->
      currentTime = new Date()
      topic = $.validateCardExpiry currentTime.getMonth() + 1, currentTime.getFullYear() + 1
      assert.equal topic, true

    it 'that has string numbers', ->
      currentTime = new Date()
      currentTime.setFullYear(currentTime.getFullYear() + 1, currentTime.getMonth() + 2)
      topic = $.validateCardExpiry currentTime.getMonth() + '', currentTime.getFullYear() + ''
      assert.equal topic, true

    it 'that has non-numbers', ->
      topic = $.validateCardExpiry 'h12', '3300'
      assert.equal topic, false

    it 'should fail if year or month is NaN', ->
      topic = $.validateCardExpiry '12', NaN
      assert.equal topic, false

  describe 'Parsing an expiry value', ->
    it 'should parse string expiry', ->
      topic = $.cardExpiryVal('03 / 2025')
      assert.deepEqual topic, month: 3, year: 2025

    it 'should support shorthand year', ->
      topic = $.cardExpiryVal('05/04')
      assert.deepEqual topic, month: 5, year: 2004

    it 'should return NaN when it cannot parse', ->
      topic = $.cardExpiryVal('05/dd')
      assert isNaN(topic.year)

  describe 'Getting a card type', ->
    it 'should return Visa that begins with 40', ->
      topic = $.cardType '4012121212121212'
      assert.equal topic, 'visa'

    it 'that begins with 5 should return MasterCard', ->
      topic = $.cardType '5555555555554444'
      assert.equal topic, 'mastercard'

    it 'that begins with 34 should return American Express', ->
      topic = $.cardType '3412121212121212'
      assert.equal topic, 'amex'

    it 'that is not numbers should return null', ->
      topic = $.cardType 'aoeu'
      assert.equal topic, null

    it 'that has unrecognized beginning numbers should return null', ->
      topic = $.cardType 'aoeu'
      assert.equal topic, null

    it 'should return correct type for all test numbers', ->
      assert.equal($.cardType('378282246310005'), 'amex')
      assert.equal($.cardType('371449635398431'), 'amex')
      assert.equal($.cardType('378734493671000'), 'amex')

      assert.equal($.cardType('30569309025904'), 'dinersclub')
      assert.equal($.cardType('38520000023237'), 'dinersclub')

      assert.equal($.cardType('6011111111111117'), 'discover')
      assert.equal($.cardType('6011000990139424'), 'discover')

      assert.equal($.cardType('3530111333300000'), 'jcb')
      assert.equal($.cardType('3566002020360505'), 'jcb')

      assert.equal($.cardType('5555555555554444'), 'mastercard')

      assert.equal($.cardType('4111111111111111'), 'visa')
      assert.equal($.cardType('4012888888881881'), 'visa')
      assert.equal($.cardType('4222222222222'), 'visa')

      assert.equal($.cardType('6759649826438453'), 'maestro')

      assert.equal($.cardType('6271136264806203568'), 'unionpay')
      assert.equal($.cardType('6236265930072952775'), 'unionpay')
      assert.equal($.cardType('6204679475679144515'), 'unionpay')
      assert.equal($.cardType('6216657720782466507'), 'unionpay')

  describe 'formatCardNumber', ->
    it 'should format cc number correctly', ->
      $number = $('<input type=text>').formatCardNumber()
      $number.val('4242')

      e = $.Event('keypress');
      e.which = 52 # '4'
      $number.trigger(e)

      assert.equal $number.val(), '4242 4'

  describe 'formatCardExpiry', ->
    it 'should format month shorthand correctly', ->
      $expiry = $('<input type=text>').formatCardExpiry()

      e = $.Event('keypress');
      e.which = 52 # '4'
      $expiry.trigger(e)

      assert.equal $expiry.val(), '04 / '

    it 'should format forward slash shorthand correctly', ->
      $expiry = $('<input type=text>').formatCardExpiry()
      $expiry.val('1')

      e = $.Event('keypress');
      e.which = 47 # '/'
      $expiry.trigger(e)

      assert.equal $expiry.val(), '01 / '

    it 'should only allow numbers', ->
      $expiry = $('<input type=text>').formatCardExpiry()
      $expiry.val('1')

      e = $.Event('keypress');
      e.which = 100 # 'd'
      $expiry.trigger(e)

      assert.equal $expiry.val(), '1'