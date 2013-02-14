$            = jQuery
$.payment    = {}
$.payment.fn = {}
$.fn.payment = (method, args...) ->
  $.payment.fn[method].apply(this, args)

# Utils

cards = [
  {
      type: 'maestro'
      pattern: /^(5018|5020|5038|6304|6759|676[1-3])/
      length: [12..19]
      cvcLength: [3]
      luhn: true
  }
  {
      type: 'dinersclub'
      pattern: /^(36|38|30[0-5])/
      length: [14]
      cvcLength: [3]
      luhn: true
  }
  {
      type: 'laser'
      pattern: /^(6706|6771|6709)/
      length: [16..19]
      cvcLength: [3]
      luhn: true
  }
  {
      type: 'jcb'
      pattern: /^35/
      length: [16]
      cvcLength: [3]
      luhn: true
  }
  {
      type: 'unionpay'
      pattern: /^62/
      length: [16..19]
      luhn: false
  }
  {
      type: 'discover'
      pattern: /^(6011|65|64[4-9]|622)/
      length: [16]
      cvcLength: [3]
      luhn: true
  }
  {
      type: 'mastercard'
      pattern: /^5[1-5]/
      length: [16]
      cvcLength: [3]
      luhn: true
  }
  {
      type: 'amex'
      pattern: /^3[47]/
      length: [15]
      cvcLength: [3..4]
      luhn: true
  }
  {
      type: 'visa'
      pattern: /^4/
      length: [13..16]
      cvcLength: [3]
      luhn: true
  }
]

cardFromNumber = (num) ->
  num = (num + '').replace(/\D/g, '')
  return card for card in cards when card.pattern.test(num)

cardFromType = (type) ->
  return card for card in cards when card.type is type

luhnCheck = (num) ->
  odd = true
  sum = 0

  digits = (num + '').split('').reverse()

  for digit in digits
    digit = parseInt(digit, 10)
    digit *= 2 if (odd = !odd)
    digit -= 9 if digit > 9
    sum += digit

  sum % 10 == 0

hasTextSelected = ($target) ->
  # If some text is selected
  return true if $target.prop('selectionStart')? and
    $target.prop('selectionStart') isnt $target.prop('selectionEnd')

  # If some text is selected in IE
  return true if document?.selection?.createRange?().text

  false

# Private

# Format Card Number

formatCardNumber = (e) ->
  if e.which
    digit = String.fromCharCode(e.which)
    return unless /^\d+$/.test(digit)
    $target = $(e.currentTarget)
  else
    digit = ""
    $target = e
  value = $target.val()
  card = cardFromNumber(value + digit)
  length = (value.replace(/\D/g, "") + digit).length
  upperLength = 16
  upperLength = card.length[card.length.length - 1]  if card
  return  if (digit.length > 0) and (length >= upperLength)
  if ($target.prop("selectionStart")?) and $target.prop("selectionStart") isnt value.length
    return
  if card and card.type is "amex"
    re = /^(\d{4}|\d{4}\s\d{6})$/
  else
    re = /(?:^|\s)(\d{4})$/
  if re.test(value)
    e.preventDefault()
    $target.val value + " " + digit
  else if re.test(value + digit)
    e.preventDefault()
    $target.val value + digit + " "
  else
    if (length >= 15) and (length is value.length)
      re = /\d/
      amex = /^3[47]/
      if re.test(value) and amex.test(value)
        $target.val value.replace(/^(\d{4})(.*?)/g, "$1 ").replace(/(\s\d{6})(.*?)/g, "$1 ").replace(/(^\s+|\s+$)/, "")
      else $target.val value.replace(/(\d{4})/g, "$1 ").replace(/(^\s+|\s+$)/, "") if re.test(value)
    else
      $target.val '' if digit.length == 0
  
formatBackCardNumber = (e) ->
  $target = $(e.currentTarget)
  value   = $target.val()

  return if e.meta

  # Return if focus isn't at the end of the text
  return if $target.prop('selectionStart')? and
    $target.prop('selectionStart') isnt value.length

  # If we're backspacing, remove the trailing space
  if e.which is 8 and /\s\d?$/.test(value)
    e.preventDefault()
    $target.val(value.replace(/\s\d?$/, ''))

# Format Expiry

formatExpiry = (e) ->
  # Only format if input is a number
  digit = String.fromCharCode(e.which)
  return unless /^\d+$/.test(digit)

  $target = $(e.currentTarget)
  val     = $target.val() + digit

  if /^\d$/.test(val) and val not in ['0', '1']
    e.preventDefault()
    $target.val("0#{val} / ")

  else if /^\d\d$/.test(val)
    e.preventDefault()
    $target.val("#{val} / ")

formatForwardExpiry = (e) ->
  digit = String.fromCharCode(e.which)
  return unless /^\d+$/.test(digit)

  $target = $(e.currentTarget)
  val     = $target.val()

  if /^\d\d$/.test(val)
    $target.val("#{val} / ")

formatForwardSlash = (e) ->
  slash = String.fromCharCode(e.which)
  return unless slash is '/'

  $target = $(e.currentTarget)
  val     = $target.val()

  if /^\d$/.test(val) and val isnt '0'
    $target.val("0#{val} / ")

formatBackExpiry = (e) ->
  # If shift+backspace is pressed
  return if e.meta

  $target = $(e.currentTarget)
  value   = $target.val()

  # Return unless backspacing
  return unless e.which is 8

  # Return if focus isn't at the end of the text
  return if $target.prop('selectionStart')? and
    $target.prop('selectionStart') isnt value.length

  # Remove the trailing space
  if /\s\/\s?$/.test(value)
    e.preventDefault()
    $target.val(value.replace(/\s\/\s?$/, ''))

#  Restrictions

restrictNumeric = (e) ->
  # Key event is for a browser shortcut
  return true if e.metaKey

  # If keycode is a space
  return false if e.which is 32

  # If keycode is a special char (WebKit)
  return true if e.which is 0

  # If char is a special char (Firefox)
  return true if e.which < 33

  char = String.fromCharCode(e.which)

  # Char is a number or a space
  !!/[\d\s]/.test(char)

restrictCardNumber = (e) ->
  $target = $(e.currentTarget)
  digit   = String.fromCharCode(e.which)
  return unless /^\d+$/.test(digit)

  return if hasTextSelected($target)

  # Restrict number of digits
  value = ($target.val() + digit).replace(/\D/g, '')
  card  = cardFromNumber(value)

  if card
    value.length <= card.length[card.length.length - 1]
  else
    # All other cards are 16 digits long
    value.length <= 16

restrictExpiry = (e) ->
  $target = $(e.currentTarget)
  digit   = String.fromCharCode(e.which)
  return unless /^\d+$/.test(digit)

  return if hasTextSelected($target)

  value = $target.val() + digit
  value = value.replace(/\D/g, '')

  return false if value.length > 6

restrictCVC = (e) ->
  $target = $(e.currentTarget)
  digit   = String.fromCharCode(e.which)
  return unless /^\d+$/.test(digit)

  val     = $target.val() + digit
  val.length <= 4

setCardType = (e) ->
  $target  = $(e.currentTarget)
  val      = $target.val()
  cardType = $.payment.cardType(val) or 'unknown'

  unless $target.hasClass(cardType)
    allTypes = (card.type for card in cards)

    $target.removeClass('unknown')
    $target.removeClass(allTypes.join(' '))

    $target.addClass(cardType)
    $target.toggleClass('identified', cardType isnt 'unknown')
    $target.trigger('payment.cardType', cardType)


# Public

# Formatting

$.payment.fn.formatCardCVC = ->
  @payment('restrictNumeric')
  @on('keypress', restrictCVC)
  this

$.payment.fn.formatCardExpiry = ->
  @payment('restrictNumeric')
  @on('keypress', restrictExpiry)
  @on('keypress', formatExpiry)
  @on('keypress', formatForwardSlash)
  @on('keypress', formatForwardExpiry)
  @on('keydown',  formatBackExpiry)
  this

$.payment.fn.formatCardNumber = ->
  a = this
  a.payment('restrictNumeric')
  a.on 'keypress', restrictCardNumber
  a.on 'keypress', formatCardNumber
  a.on 'keydown', formatBackCardNumber
  a.on 'keyup', setCardType
  a.on 'paste', ->
      setTimeout (->
          formatCardNumber a
      ), 5
  this

# Restrictions

$.payment.fn.restrictNumeric = ->
  @on('keypress', restrictNumeric)
  this

# Validations

$.payment.fn.cardExpiryVal = ->
  $.payment.cardExpiryVal($(this).val())

$.payment.cardExpiryVal = (value) ->
  value = value.replace(/\s/g, '')
  [month, year] = value.split('/', 2)

  # Allow for year shortcut
  if year?.length is 2 and /^\d+$/.test(year)
    prefix = (new Date).getFullYear()
    prefix = prefix.toString()[0..1]
    year   = prefix + year

  month = parseInt(month, 10)
  year  = parseInt(year, 10)

  month: month, year: year

$.payment.validateCardNumber = (num) ->
  num = (num + '').replace(/\s+|-/g, '')
  return false unless /^\d+$/.test(num)

  card = cardFromNumber(num)
  return false unless card

  num.length in card.length and
    (card.luhn is false or luhnCheck(num))

$.payment.validateCardExpiry = (month, year) =>
  # Allow passing an object
  if typeof month is 'object' and 'month' of month
    {month, year} = month

  return false unless month and year

  month = $.trim(month)
  year  = $.trim(year)

  return false unless /^\d+$/.test(month)
  return false unless /^\d+$/.test(year)
  return false unless parseInt(month, 10) <= 12

  expiry      = new Date(year, month)
  currentTime = new Date

  # Months start from 0 in JavaScript
  expiry.setMonth(expiry.getMonth() - 1)

  # The cc expires at the end of the month,
  # so we need to make the expiry the first day
  # of the month after
  expiry.setMonth(expiry.getMonth() + 1, 1)

  expiry > currentTime

$.payment.validateCardCVC = (cvc, type) ->
  cvc = $.trim(cvc)
  return false unless /^\d+$/.test(cvc)

  if type
    # Check against a explicit card type
    cvc.length in cardFromType(type)?.cvcLength
  else
    # Check against all types
    cvc.length >= 3 and cvc.length <= 4

$.payment.cardType = (num) ->
  return null unless num
  cardFromNumber(num)?.type or null
