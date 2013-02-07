# jQuery.payment

A general purpose library for building credit card forms, validating inputs and formatting numbers.

For example, you can make a input act like a credit card field (with number formatting, and length restriction):

``` javascript
$('input.cc-num').formatCardNumber();
```

Then, when say the payment form is submitted, you can validate the card number on the client-side like so:

``` javascript
var valid = $.validateCardNumber($('input.cc-num').val());

if ( !valid ) {
  alert('Your card is not valid!');
  return false;
}
```

You can find a full [demo here](http://stripe.github.com/jquery.payment/example).

Supported card types are:

* Visa
* MasterCard
* American Express
* Discover
* JCB
* Diners Club
* Maestro
* Laster
* UnionPay

## API

### $.fn.formatCardNumber()

Formats card numbers:

* Including a space between every 4 digits
* Restricts input to numbers
* Limits to 16 numbers
* American Express formatting support
* Adds a class of the card type (i.e. 'visa') to the input

Example:

``` javascript
$('input.cc-num').formatCardNumber();
```

### $.fn.formatCardExpiry()

Formats card expiry:

* Includes a `/` between the month and year
* Restricts input to numbers
* Restricts length

Example:

``` javascript
$('input.cc-exp').formatCardExpiry();
```

### $.fn.formatCardCVC()

Formats card CVC:

* Restricts length to 4 numbers
* Restricts input to numbers

Example:

``` javascript
$('input.cc-cvc').formatCardCVC();
```

### $.fn.restrictNumeric()

General numeric input restriction.

Example:

``` javascript
$('data-numeric').restrictNumeric();
```

### $.validateCardNumber(number)

Validates a card number:

* Validates numbers
* Validates Luhn algorithm
* Validates length

Example:

``` javascript
$.validateCardNumber('4242 4242 4242 4242'); //=> true
```

### $.validateCardExpiry(month, year)

Validates a card expiry:

* Validates numbers
* Validates in the future
* Supports year shorthand

Example:

``` javascript
$.validateCardExpiry('05', '20'); //=> true
$.validateCardExpiry('05', '2015'); //=> true
$.validateCardExpiry('05', '05'); //=> false
```

### $.validateCardCVC(cvc, type)

Validates a card CVC:

* Validates number
* Validates length to 4

Example:

``` javascript
$.validateCardCVC('123'); //=> true
$.validateCardCVC('123', 'amex'); //=> false
$.validateCardCVC('1234', 'amex'); //=> true
$.validateCardCVC('12344'); //=> false
```

### $.cardType(number)

Returns a card type. Either:

* `visa`
* `mastercard`
* `amex`
* `dinersclub`
* `maestro`
* `laser`
* `unionpay`

The function will return `null` if the card type can't be determined.

Example:

``` javascript
$.cardType('4242 4242 4242 4242'); //=> 'visa'
```

### $.cardExpiryVal(string) and $.fn.cardExpiryVal()

Parses a credit card expiry in the form of MM/YYYY, returning an object containing the `month` and `year`. Shorthand years, such as `13` are also supported (and converted into the longhand, e.g. `2013`).

``` javascript
$.cardExpiryVal('03 / 2025'); //=> {month: 3: year: 2025}
$.cardExpiryVal('05 / 04'); //=> {month: 5, year: 2004}
$('input.cc-exp').cardExpiryVal() //=> {month: 4, year: 2020}
```

This function doesn't do any validation of the month or year, use `$.validateCardExpiry(month, year)` for that.

## Example

Look in `./example/index.html`

## Building

Run `cake build`

## Run tests

Run `mocha --compilers coffee:coffee-script`

## Autocomplete recommendations

We recommend you turn autocomplete on for credit card forms, except for the CVC field. You can do this by setting the `autocomplete` attribute:

``` html
<form autocomplete="on">
  <input class="cc-number">
  <input class="cc-cvc" autocomplete="off">
</form>
```

You should also mark up your fields using the [Autocomplete Types spec](http://wiki.whatwg.org/wiki/Autocomplete_Types). These are respected by a number of browsers, including Chrome.

``` html
<input type="text" class="cc-number" pattern="\d*" autocompletetype="cc-number" placeholder="Card number" required>
```

Set `autocompletetype` to `cc-number` for credit card numbers, `cc-exp` for credit card expiry and `cc-csc` for the CVC (security code).

## Mobile recommendations

We recommend you set the `pattern` attribute which will cause the numeric keyboard to be displayed on mobiles:

``` html
<input class="cc-number" pattern="\d*">
```

You may have to turn off HTML5 validation (using the `novalidate` form attribute) when using this `pattern`, as it won't match space formatting.