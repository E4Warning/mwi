# Wind cut-off used by the index

The wind speed above which the index is forced to zero, exposed as a
function so that the constant is stated in exactly one place.

## Usage

``` r
mwi_wind_threshold(units = c("km/h", "m/s"))
```

## Arguments

- units:

  Units in which to return the threshold: `"km/h"` (the default) or
  `"m/s"`.

## Value

A length-one numeric vector.

## Examples

``` r
mwi_wind_threshold()
#> [1] 21.6
mwi_wind_threshold("m/s")
#> [1] 6
```
