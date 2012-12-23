$ = jQuery

# Utils

trim = (str) ->
  (str + '').replace(/^\s+|\s+$/g, '')

cardTypes = do ->
    types = {}
    types[num] = 'visa' for num in [40..49]
    types[num] = 'mastercard' for num in [50..59]
    types[34] = types[37] = 'amex'
    types[60] = types[62] = types[64] = types[65] = 'discover'
    types[35] = 'jcb'
    types[30] = types[36] = types[38] = types[39] = 'dinersclub'
    types

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

# Private

# Format Card Number

formatCardNumber = (e) ->
  # Only format if input is a number
  digit = String.fromCharCode(e.which)
  return unless /^\d+$/.test(digit)

  $target = $(e.currentTarget)
  value   = $target.val()
  type    = $.cardType(value + digit)
  length  = (value.replace(/\D/g, '') + digit).length

  if type is 'amex'
    # Amex are 15 digits
    return if length >= 15
  else
    return if length >= 16

  # Return if focus isn't at the end of the text
  return if $target.prop('selectionStart')? and
    $target.prop('selectionStart') isnt value.length

  if type is 'amex'
    # Amex cards are formatted differently
    re = /^(\d{4}|\d{4}\s\d{6})$/
  else
    re = /(?:^|\s)(\d{4})$/

  # If '4242' + 4
  if re.test(value)
    e.preventDefault()
    $target.val(value + ' ' + digit)

  # If '424' + 2
  else if re.test(value + digit)
    e.preventDefault()
    $target.val(value + digit + ' ')

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
  val     = $target.val()
  val     += digit

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

formatBackExpiry = (e) ->
  # If shift+backspace is pressed
  return if e.meta

  $target = $(e.currentTarget)
  value   = $target.val()

  # Return if focus isn't at the end of the text
  return if $target.prop('selectionStart')? and
    $target.prop('selectionStart') isnt value.length

  # If we're backspacing, remove the trailing space
  if e.which is 8 and /\s\/\s?$/.test(value)
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

  # If some text is selected
  return if $target.prop('selectionStart')? and
    $target.prop('selectionStart') isnt $target.prop('selectionEnd')

  # If some text is selected in IE
  return if document.selection?.createRange?().text

  # Restrict number of digits
  value = $target.val() + digit
  value = value.replace(/\D/g, '')

  if $.cardType(value) is 'amex'
    # Amex are 15 digits long
    value.length <= 15
  else
    # All other cards are 16 digits long
    value.length <= 16

restrictCVC = (e) ->
  $target = $(e.currentTarget)
  val     = $target.val()
  val.length <= 4

# Public

# Formatting

$.fn.formatCardCVC = ->
  @restrictNumeric()
  @on('keypress', restrictCVC)

$.fn.formatCardExpiry = ->
  @restrictNumeric()
  @on('keypress', formatExpiry)
  @on('keypress', formatForwardExpiry)
  @on('keydown',  formatBackExpiry)

$.fn.formatCardNumber = ->
  @restrictNumeric()
  @on('keypress', restrictCardNumber)
  @on('keypress', formatCardNumber)
  @on('keydown', formatBackCardNumber)

# Restrictions

$.fn.restrictNumeric = ->
  @on('keypress', restrictNumeric)

# Validations

$.validateCardNumber = (num) ->
  num = (num + '').replace(/\s+|-/g, '')
  num.length >= 10 and num.length <= 16 and luhnCheck(num)

$.validateCardExpiry = (month, year) =>
  if year?
    month = trim(month)
    year  = trim(year)

  else
    expiry = month.replace(/\s/g, '')
    [month, year] = expiry.split('/', 2)

    # Allow for year shortcut
    if year?.length is 2
      prefix = (new Date).getFullYear()
      prefix = prefix.toString()[0..1]
      year   = prefix + year

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

$.validateCardCVC = (cvc, type) ->
  cvc = trim(cvc)
  return false unless /^\d+$/.test(cvc)

  if type
    # Check against a explicit card type
    if type is 'amex'
      cvc.length is 4
    else
      cvc.length is 3
  else
    # Check against all types
    cvc.length >= 3 and cvc.length <= 4

$.cardType = (num) ->
  cardTypes[num[0..1]] or null