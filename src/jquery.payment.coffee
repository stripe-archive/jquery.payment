$ = window.jQuery or window.Zepto or window.$
$.payment = {}
$.payment.fn = {}
$.fn.payment = (method, args...) ->
  $.payment.fn[method].apply(this, args)

# Utils

defaultFormat = /(\d{1,4})/g

$.payment.cards = cards = [
  {
    type: 'maestro'
    patterns: [
      5018, 502, 503, 506, 56, 58, 639, 6220, 67
    ]
    format: defaultFormat
    length: [12..19]
    cvcLength: [3]
    luhn: true
  }
  {
    type: 'forbrugsforeningen'
    patterns: [600]
    format: defaultFormat
    length: [16]
    cvcLength: [3]
    luhn: true
  }
  {
    type: 'dankort'
    patterns: [5019]
    format: defaultFormat
    length: [16]
    cvcLength: [3]
    luhn: true
  }
  # Credit cards
  {
    type: 'visa'
    patterns: [4]
    format: defaultFormat
    length: [13, 16]
    cvcLength: [3]
    luhn: true
  }
  {
    type: 'mastercard'
    patterns: [
      51, 52, 53, 54, 55,
      22, 23, 24, 25, 26, 27
    ]
    format: defaultFormat
    length: [16]
    cvcLength: [3]
    luhn: true
  }
  {
    type: 'amex'
    patterns: [34, 37]
    format: /(\d{1,4})(\d{1,6})?(\d{1,5})?/
    length: [15]
    cvcLength: [3..4]
    luhn: true
  }
  {
    type: 'dinersclub'
    patterns: [30, 36, 38, 39]
    format: /(\d{1,4})(\d{1,6})?(\d{1,4})?/
    length: [14]
    cvcLength: [3]
    luhn: true
  }
  {
    type: 'discover'
    patterns: [60, 64, 65, 622]
    format: defaultFormat
    length: [16]
    cvcLength: [3]
    luhn: true
  }
  {
    type: 'unionpay'
    patterns: [62, 88]
    format: defaultFormat
    length: [16..19]
    cvcLength: [3]
    luhn: false
  }
  {
    type: 'jcb'
    patterns: [35]
    format: defaultFormat
    length: [16]
    cvcLength: [3]
    luhn: true
  }
]

cardFromNumber = (num) ->
  num = (num + '').replace(/\D/g, '')
  for card in cards
    for pattern in card.patterns
      p = pattern + ''
      return card if num.substr(0, p.length) == p

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
  if document?.selection?.createRange?
    return true if document.selection.createRange().text

  false

# Private

# Safe Val

safeVal = (value, $target) ->
  try
    cursor = $target.prop('selectionStart')
  catch error
    cursor = null
  last = $target.val()
  $target.val(value)
  if cursor != null && $target.is(":focus")
    cursor = value.length if cursor is last.length

    # This hack looks for scenarios where we are changing an input's value such
    # that "X| " is replaced with " |X" (where "|" is the cursor). In those
    # scenarios, we want " X|".
    #
    # For example:
    # 1. Input field has value "4444| "
    # 2. User types "1"
    # 3. Input field has value "44441| "
    # 4. Reformatter changes it to "4444 |1"
    # 5. By incrementing the cursor, we make it "4444 1|"
    #
    # This is awful, and ideally doesn't go here, but given the current design
    # of the system there does not appear to be a better solution.
    #
    # Note that we can't just detect when the cursor-1 is " ", because that
    # would incorrectly increment the cursor when backspacing, e.g. pressing
    # backspace in this scenario: "4444 1|234 5".
    if last != value
      prevPair = last[cursor-1..cursor]
      currPair = value[cursor-1..cursor]
      digit = value[cursor]
      cursor = cursor + 1 if /\d/.test(digit) and
        prevPair == "#{digit} " and currPair == " #{digit}"

    $target.prop('selectionStart', cursor)
    $target.prop('selectionEnd', cursor)

# Replace Full-Width Chars

replaceFullWidthChars = (str = '') ->
  fullWidth = '\uff10\uff11\uff12\uff13\uff14\uff15\uff16\uff17\uff18\uff19'
  halfWidth = '0123456789'

  value = ''
  chars = str.split('')

  # Avoid using reserved word `char`
  for chr in chars
    idx = fullWidth.indexOf(chr)
    chr = halfWidth[idx] if idx > -1
    value += chr

  value

# Format Numeric

reFormatNumeric = (e) ->
  $target = $(e.currentTarget)
  setTimeout ->
    value   = $target.val()
    value   = replaceFullWidthChars(value)
    value   = value.replace(/\D/g, '')
    safeVal(value, $target)

# Format Card Number

reFormatCardNumber = (e) ->
  $target = $(e.currentTarget)
  setTimeout ->
    value   = $target.val()
    value   = replaceFullWidthChars(value)
    value   = $.payment.formatCardNumber(value)
    safeVal(value, $target)

formatCardNumber = (e) ->
  # Only format if input is a number
  digit = String.fromCharCode(e.which)
  return unless /^\d+$/.test(digit)

  $target = $(e.currentTarget)
  value   = $target.val()
  card    = cardFromNumber(value + digit)
  length  = (value.replace(/\D/g, '') + digit).length

  upperLength = 16
  upperLength = card.length[card.length.length - 1] if card
  return if length >= upperLength

  # Return if focus isn't at the end of the text
  return if $target.prop('selectionStart')? and
    $target.prop('selectionStart') isnt value.length

  if card && card.type is 'amex'
    # AMEX cards are formatted differently
    re = /^(\d{4}|\d{4}\s\d{6})$/
  else
    re = /(?:^|\s)(\d{4})$/

  # If '4242' + 4
  if re.test(value)
    e.preventDefault()
    setTimeout -> $target.val(value + ' ' + digit)

  # If '424' + 2
  else if re.test(value + digit)
    e.preventDefault()
    setTimeout -> $target.val(value + digit + ' ')

formatBackCardNumber = (e) ->
  $target = $(e.currentTarget)
  value   = $target.val()

  # Return unless backspacing
  return unless e.which is 8

  # Return if focus isn't at the end of the text
  return if $target.prop('selectionStart')? and
    $target.prop('selectionStart') isnt value.length

  # Remove the digit + trailing space
  if /\d\s$/.test(value)
    e.preventDefault()
    setTimeout -> $target.val(value.replace(/\d\s$/, ''))
  # Remove digit if ends in space + digit
  else if /\s\d?$/.test(value)
    e.preventDefault()
    setTimeout -> $target.val(value.replace(/\d$/, ''))

# Format Expiry

reFormatExpiry = (e) ->
  $target = $(e.currentTarget)
  setTimeout ->
    value   = $target.val()
    value   = replaceFullWidthChars(value)
    value   = $.payment.formatExpiry(value)
    safeVal(value, $target)

formatExpiry = (e) ->
  # Only format if input is a number
  digit = String.fromCharCode(e.which)
  return unless /^\d+$/.test(digit)

  $target = $(e.currentTarget)
  val     = $target.val() + digit

  if /^\d$/.test(val) and val not in ['0', '1']
    e.preventDefault()
    setTimeout -> $target.val("0#{val} / ")

  else if /^\d\d$/.test(val)
    e.preventDefault()
    setTimeout ->
      # Split for months where we have the second digit > 2 (past 12) and turn
      # that into (m1)(m2) => 0(m1) / (m2)
      m1 = parseInt(val[0], 10)
      m2 = parseInt(val[1], 10)
      if m2 > 2 and m1 != 0
        $target.val("0#{m1} / #{m2}")
      else
        $target.val("#{val} / ")

formatForwardExpiry = (e) ->
  digit = String.fromCharCode(e.which)
  return unless /^\d+$/.test(digit)

  $target = $(e.currentTarget)
  val     = $target.val()

  if /^\d\d$/.test(val)
    $target.val("#{val} / ")

formatForwardSlashAndSpace = (e) ->
  which = String.fromCharCode(e.which)
  return unless which is '/' or which is ' '

  $target = $(e.currentTarget)
  val     = $target.val()

  if /^\d$/.test(val) and val isnt '0'
    $target.val("0#{val} / ")

formatBackExpiry = (e) ->
  $target = $(e.currentTarget)
  value   = $target.val()

  # Return unless backspacing
  return unless e.which is 8

  # Return if focus isn't at the end of the text
  return if $target.prop('selectionStart')? and
    $target.prop('selectionStart') isnt value.length

  # Remove the trailing space + last digit
  if /\d\s\/\s$/.test(value)
    e.preventDefault()
    setTimeout -> $target.val(value.replace(/\d\s\/\s$/, ''))

# Format CVC

reFormatCVC = (e) ->
  $target = $(e.currentTarget)
  setTimeout ->
    value   = $target.val()
    value   = replaceFullWidthChars(value)
    value   = value.replace(/\D/g, '')[0...4]
    safeVal(value, $target)

# Restrictions

restrictNumeric = (e) ->
  # Key event is for a browser shortcut
  return true if e.metaKey or e.ctrlKey

  # If keycode is a space
  return false if e.which is 32

  # If keycode is a special char (WebKit)
  return true if e.which is 0

  # If char is a special char (Firefox)
  return true if e.which < 33

  input = String.fromCharCode(e.which)

  # Char is a number or a space
  !!/[\d\s]/.test(input)

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

  return if hasTextSelected($target)

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
  @on('keypress.payment', restrictNumeric)
  @on('keypress.payment', restrictCVC)
  @on('paste.payment', reFormatCVC)
  @on('change.payment', reFormatCVC)
  @on('input.payment', reFormatCVC)
  this

$.payment.fn.formatCardExpiry = ->
  @on('keypress.payment', restrictNumeric)
  @on('keypress.payment', restrictExpiry)
  @on('keypress.payment', formatExpiry)
  @on('keypress.payment', formatForwardSlashAndSpace)
  @on('keypress.payment', formatForwardExpiry)
  @on('keydown.payment',  formatBackExpiry)
  @on('change.payment', reFormatExpiry)
  @on('input.payment', reFormatExpiry)
  this

$.payment.fn.formatCardNumber = ->
  @on('keypress.payment', restrictNumeric)
  @on('keypress.payment', restrictCardNumber)
  @on('keypress.payment', formatCardNumber)
  @on('keydown.payment', formatBackCardNumber)
  @on('keyup.payment', setCardType)
  @on('paste.payment', reFormatCardNumber)
  @on('change.payment', reFormatCardNumber)
  @on('input.payment', reFormatCardNumber)
  @on('input.payment', setCardType)
  this

# Restrictions

$.payment.fn.restrictNumeric = ->
  @on('keypress.payment', restrictNumeric)
  @on('paste.payment', reFormatNumeric)
  @on('change.payment', reFormatNumeric)
  @on('input.payment', reFormatNumeric)
  this

# Validations

$.payment.fn.cardExpiryVal = ->
  $.payment.cardExpiryVal($(this).val())

$.payment.cardExpiryVal = (value) ->
  [month, year] = value.split(/[\s\/]+/, 2)

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

$.payment.validateCardExpiry = (month, year) ->
  # Allow passing an object
  if typeof month is 'object' and 'month' of month
    {month, year} = month

  return false unless month and year

  month = $.trim(month)
  year  = $.trim(year)

  return false unless /^\d+$/.test(month)
  return false unless /^\d+$/.test(year)
  return false unless 1 <= month <= 12

  if year.length == 2
    if year < 70
      year = "20#{year}"
    else
      year = "19#{year}"

  return false unless year.length == 4

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

  card = cardFromType(type)
  if card?
    # Check against a explicit card type
    cvc.length in card.cvcLength
  else
    # Check against all types
    cvc.length >= 3 and cvc.length <= 4

$.payment.cardType = (num) ->
  return null unless num
  cardFromNumber(num)?.type or null

$.payment.formatCardNumber = (num) ->
  num = num.replace(/\D/g, '')
  card = cardFromNumber(num)
  return num unless card

  upperLength = card.length[card.length.length - 1]
  num = num[0...upperLength]

  if card.format.global
    num.match(card.format)?.join(' ')
  else
    groups = card.format.exec(num)
    return unless groups?
    groups.shift()
    groups = $.grep(groups, (n) -> n) # Filter empty groups
    groups.join(' ')

$.payment.formatExpiry = (expiry) ->
  parts = expiry.match(/^\D*(\d{1,2})(\D+)?(\d{1,4})?/)
  return '' unless parts

  mon = parts[1] || ''
  sep = parts[2] || ''
  year = parts[3] || ''

  if year.length > 0
    sep = ' / '

  else if sep is ' /'
    mon = mon.substring(0, 1)
    sep = ''

  else if mon.length == 2 or sep.length > 0
    sep = ' / '

  else if mon.length == 1 and mon not in ['0', '1']
    mon = "0#{mon}"
    sep = ' / '

  return mon + sep + year
