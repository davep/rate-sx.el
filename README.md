# rate-sx.el

Display output from [rate.sx](http://rate.sx) in a buffer.

## Commentary:

`rate-sx.el` provides a main command, `rate-sx`, which displays the output
of [rate.sx](http://rate.sx) in a buffer.

Other commands provide ways to quickly calculate currency totals, they
include:

### `rate-sx-calc`

Show the result of a currency calculation in the minibuffer. Calculations
are things like `1BTC+12ETH` (would show the total value, in the base
currency defined by `rate-sx-default-currency`, of holding 1 BTC and 12ETH).

### `rate-sx-calc-region`

Same as above but takes the input from the content of the marked region.

### `rate-sx-calc-maybe-region`

Same as above again, but performs `rate-sx-calc-region` if there is an
active mark, otherwise it performs `rate-sx-calc`.
