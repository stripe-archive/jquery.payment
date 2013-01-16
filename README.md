# jQuery.payment

A general purpose library for building credit card forms, validating inputs and formatting numbers.

For example, you can make a input act like a credit card field (with number formatting, and length restriction):

    $('input.cc-num').formatCardNumber();

Then, when say the payment form is submitted, you can validate the card number on the client-side like so:

    var valid = $.validateCardNumber($('input.cc-num').val());

    if ( !valid ) {
      alert('Your card is not valid!');
      return false;
    }

You can find a full [demo here](http://stripe.github.com/jquery.payment/example).

## API

### $.fn.formatCardNumber()

Formats card numbers:

* Including a space between every 4 digits
* Restricts input to numbers
* Limits to 16 numbers
* American Express formatting support
* Adds a class of the card type (i.e. 'visa') to the input

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

    <input type="text" class="cc-number" pattern="\d*" autocompletetype="cc-number" placeholder="Card number" required>

Set `autocompletetype` to `cc-number` for credit card numbers, `cc-exp` for credit card expiry and `cc-csc` for the CVC (security code).

## Mobile recommendations

We recommend you set the `pattern` attribute which will cause the numeric keyboard to be displayed on mobiles:

    <input class="cc-number" pattern="\d*">

You may have to turn off HTML5 validation (using the `novalidate` form attribute) when using this `pattern`, as it won't match space formatting.