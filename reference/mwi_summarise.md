# Summarise sub-daily weather into index values, in the correct order

Computes the Mosquito Weather Index at the resolution of the supplied
observations and only then summarises it within each group. This is the
order the index requires, and getting it the wrong way round is the most
common way to misuse it.

## Usage

``` r
mwi_summarise(
  temperature,
  humidity,
  wind_speed,
  by = NULL,
  statistic = c("max", "mean", "min"),
  units = c("km/h", "m/s"),
  na.rm = FALSE
)
```

## Arguments

- temperature:

  Numeric vector of air temperatures in degrees Celsius.

- humidity:

  Numeric vector of relative humidities in percent (0-100).

- wind_speed:

  Numeric vector of wind speeds, in the units given by `units`.

- by:

  Grouping vector the same length as the weather inputs, typically a
  `Date` or a day-of-year. Values are summarised within each unique
  element. Use `NULL` to summarise everything into a single value.

- statistic:

  Summary to apply within each group: `"max"` (the default), `"mean"`,
  or `"min"`.

- units:

  Units of `wind_speed`: `"km/h"` (the default) or `"m/s"`.

- na.rm:

  Whether to drop missing index values within each group. If `FALSE`
  (the default), a group containing any `NA` returns `NA`.

## Value

A data frame with one row per group and columns `by`, `mwi` and `n` (the
number of observations contributing to the group). If `by` is `NULL`, a
one-row data frame with `by = NA`.

## Details

The index is a product of non-linear response functions, so it does not
commute with averaging:
`mwi(mean(temperature), mean(humidity), mean(wind))` is not
`mean(mwi(temperature, humidity, wind))`. The discrepancy is severe with
daily maxima, because the daily maximum of relative humidity and the
daily maximum of temperature usually fall many hours apart, so an index
computed from them describes conditions that never co-occurred.

`mwi_summarise()` therefore takes sub-daily observations, evaluates
[`mwi()`](https://e4warning.github.io/mwi/reference/mwi.md) on each one,
and reduces the results with `statistic` within each level of `by`.
Empirically the maximum is the more informative summary: it captures
whether the period contained a window of favourable conditions, rather
than how favourable the period was on average.

## See also

[`mwi()`](https://e4warning.github.io/mwi/reference/mwi.md) for the
index itself.

## Examples

``` r
# One synthetic day of hourly weather
hours <- 0:23
temp <- 18 + 8 * sin((hours - 6) / 24 * 2 * pi)
rh <- 75 - 15 * sin((hours - 6) / 24 * 2 * pi)
wind <- rep(5, 24)

mwi_summarise(temp, rh, wind, by = rep("2019-07-15", 24))
#>           by       mwi  n
#> 1 2019-07-15 0.5657766 24

# The wrong order gives a different answer
mwi(max(temp), max(rh), max(wind))
#> [1] 0.7272727
```
