# jQuery.payment

A general purpose library for building credit card forms, validating inputs and formatting numbers.

[Example](http://stripe.github.com/jquery.payment/example)

## API

### $.fn.formatCardNumber()

Formats card numbers:

* Including a space between every 4 digits
* Restricts input to numbers
* Limits to 16 numbers
* American Express formatting support

Example:

    $('input.cc-num').formatCardNumber();

### $.fn.formatCardExpiry()

Formats card expiry:

* Includes a `/` between the month and year
* Restricts input to numbers
* Restricts length

Example:

    $('input.cc-exp').formatCardExpiry();

### $.fn.formatCardCVC()

Formats card CVC:

* Restricts length to 4 numbers
* Restricts input to numbers

Example:

    $('input.cc-cvc').formatCardCVC();

### $.fn.restrictNumeric()

General numeric input restriction.

Example:

    $('data-numeric').restrictNumeric();

### $.validateCardNumber(number)

Validates a card number:

* Validates numbers
* Validates Luhn algorithm
* Validates length

Example:

    $.validateCardNumber('4242 4242 4242 4242'); //=> true

### $.validateCardExpiry(month, year)

Validates a card expiry:

* Validates numbers
* Validates in the future
* Supports year shorthand

Example:

    $.validateCardExpiry('05', '20'); //=> true
    $.validateCardExpiry('05', '2015'); //=> true
    $.validateCardExpiry('05', '05'); //=> false
    $.validateCardExpiry('05 / 04'); //=> false
    $.validateCardExpiry('03 / 2025'); //=> true

### $.validateCardCVC(cvc, type)

Validates a card CVC:

* Validates number
* Validates length to 4

Example:

    $.validateCardCVC('123'); //=> true
    $.validateCardCVC('123', 'amex'); //=> false
    $.validateCardCVC('1234', 'amex'); //=> true
    $.validateCardCVC('12344'); //=> false

### $.cardType(number)

Returns a card type. Either:

* `visa`
* `mastercard`
* `amex`
* `dinersclub`

The function will return `null` if the card type can't be determined.

Example:

    $.cardType('4242 4242 4242 4242'); //=> 'visa'

## Example

Look in `./example/index.html`

## Building

Run `cake build`

## Run tests

Run `mocha --compilers coffee:coffee-script`

## Autocomplete recommendations

We recommend you turn autocomplete on for credit card forms, except for the CVC field. You can do this by setting the `autocomplete` attribute:

    <form autocomplete="on">
      <input class="cc-number">
      <input class="cc-cvc" autocomplete="off">
    </form>

You should also mark up your fields using the [Autocomplete Types spec](http://wiki.whatwg.org/wiki/Autocomplete_Types). These are respected by a number of browsers, including Chrome.

    <input type="text" class="cc-number" pattern="\d*" x-autocompletetype="cc-number" placeholder="Card number" required>

Set `x-autocompletetype` to `cc-number` for credit card numbers, `cc-exp` for credit card expiry and `cc-csc` for the CVC (security code).

## Mobile recommendations

We recommend you set the `pattern` attribute which will cause the numeric keyboard to be displayed on mobiles:

    <input class="cc-number" pattern="\d*">

You may have to turn off HTML5 validation (using the `novalidate` form attribute) when using this `pattern`, as it won't match space formatting.