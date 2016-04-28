# jQuery.payment [![Build Status](https://travis-ci.org/stripe/jquery.payment.svg?branch=master)](https://travis-ci.org/stripe/jquery.payment)

A general purpose library for building credit card forms, validating inputs and formatting numbers.

## Project status

We consider `jQuery.payment` to be feature complete. We continue to use it in production, and we will happily accept bug reports and pull requests fixing those bugs, but we will not be adding new features or modifying the project for new frameworks or build systems.

### Why?

The library was born in a different age, and we think it has served tremendously, but it is fundamentally doing too many things. Complecting DOM element manipulation, input masking, card formatting, and cursor positioning makes it difficult to test and modify. An ideal version of this library would separate the independent components and make the internal logic functional.

## Usage

You can make an input act like a credit card field (with number formatting and length restriction):

``` javascript
$('input.cc-num').payment('formatCardNumber');
```

Then, when the payment form is submitted, you can validate the card number on the client-side:

``` javascript
var valid = $.payment.validateCardNumber($('input.cc-num').val());

if (!valid) {
  alert('Your card is not valid!');
  return false;
}
```

You can find a full [demo here](http://stripe.github.io/jquery.payment/example).

Supported card types are:

* Visa
* MasterCard
* American Express
* Diners Club
* Discover
* UnionPay
* JCB
* Visa Electron
* Maestro
* Forbrugsforeningen
* Dankort
* Elo

(Additional card types are supported by extending the [`$.payment.cards`](#paymentcards) array.)

## API

### $.fn.payment('formatCardNumber')

Formats card numbers:

* Includes a space between every 4 digits
* Restricts input to numbers
* Limits to 16 numbers
* Supports American Express formatting
* Adds a class of the card type (e.g. 'visa') to the input

Example:

``` javascript
$('input.cc-num').payment('formatCardNumber');
```

### $.fn.payment('formatCardExpiry')

Formats card expiry:

* Includes a `/` between the month and year
* Restricts input to numbers
* Restricts length

Example:

``` javascript
$('input.cc-exp').payment('formatCardExpiry');
```

### $.fn.payment('formatCardCVC')

Formats card CVC:

* Restricts length to 4 numbers
* Restricts input to numbers

Example:

``` javascript
$('input.cc-cvc').payment('formatCardCVC');
```

### $.fn.payment('restrictNumeric')

General numeric input restriction.

Example:

``` javascript
$('[data-numeric]').payment('restrictNumeric');
```

### $.payment.validateCardNumber(number)

Validates a card number:

* Validates numbers
* Validates Luhn algorithm
* Validates length

Example:

``` javascript
$.payment.validateCardNumber('4242 4242 4242 4242'); //=> true
```

### $.payment.validateCardExpiry(month, year)

Validates a card expiry:

* Validates numbers
* Validates in the future
* Supports year shorthand

Example:

``` javascript
$.payment.validateCardExpiry('05', '20'); //=> true
$.payment.validateCardExpiry('05', '2015'); //=> true
$.payment.validateCardExpiry('05', '05'); //=> false
```

### $.payment.validateCardCVC(cvc, type)

Validates a card CVC:

* Validates number
* Validates length to 4

Example:

``` javascript
$.payment.validateCardCVC('123'); //=> true
$.payment.validateCardCVC('123', 'amex'); //=> true
$.payment.validateCardCVC('1234', 'amex'); //=> true
$.payment.validateCardCVC('12344'); //=> false
```

### $.payment.cardType(number)

Returns a card type. Either:

* `visa`
* `mastercard`
* `amex`
* `dinersclub`
* `discover`
* `unionpay`
* `jcb`
* `visaelectron`
* `maestro`
* `forbrugsforeningen`
* `dankort`
* `elo`

The function will return `null` if the card type can't be determined.

Example:

``` javascript
$.payment.cardType('4242 4242 4242 4242'); //=> 'visa'
```

### $.payment.cardExpiryVal(string) and $.fn.payment('cardExpiryVal')

Parses a credit card expiry in the form of MM/YYYY, returning an object containing the `month` and `year`. Shorthand years, such as `13` are also supported (and converted into the longhand, e.g. `2013`).

``` javascript
$.payment.cardExpiryVal('03 / 2025'); //=> {month: 3, year: 2025}
$.payment.cardExpiryVal('05 / 04'); //=> {month: 5, year: 2004}
$('input.cc-exp').payment('cardExpiryVal') //=> {month: 4, year: 2020}
```

This function doesn't perform any validation of the month or year; use `$.payment.validateCardExpiry(month, year)` for that.

### $.payment.cards

Array of objects that describe valid card types. Each object should contain the following fields:

``` javascript
{
  // Card type, as returned by $.payment.cardType.
  type: 'mastercard',
  // Array of prefixes used to identify the card type.
  patterns: [
      51, 52, 53, 54, 55,
      22, 23, 24, 25, 26, 27
  ],
  // Array of valid card number lengths.
  length: [16],
  // Array of valid card CVC lengths.
  cvcLength: [3],
  // Boolean indicating whether a valid card number should satisfy the Luhn check.
  luhn: true,
  // Regex used to format the card number. Each match is joined with a space.
  format: /(\d{1,4})/g
}
```

When identifying a card type, the array is traversed in order until the card number matches a prefix in `patterns`. For this reason, patterns with higher specificity should appear towards the beginning of the array.

## Example

Look in [`./example/index.html`](example/index.html)

## Building

Run `cake build`

## Running tests

Run `cake test`

## Autocomplete recommendations

We recommend you turn autocomplete on for credit card forms, except for the CVC field (which should never be stored). You can do this by setting the `autocomplete` attribute:

``` html
<form autocomplete="on">
  <input class="cc-number">
  <input class="cc-cvc" autocomplete="off">
</form>
```

You should also mark up your fields using the [Autofill spec](https://html.spec.whatwg.org/multipage/forms.html#autofill). These are respected by a number of browsers, including Chrome.

``` html
<input type="tel" class="cc-number" autocomplete="cc-number">
```

Set `autocomplete` to `cc-number` for credit card numbers and `cc-exp` for credit card expiry.

## Mobile recommendations

We recommend you to use `<input type="tel">` which will cause the numeric keyboard to be displayed on mobile devices:

``` html
<input type="tel" class="cc-number">
```
