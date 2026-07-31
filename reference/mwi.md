# Mosquito Weather Index

Combines air temperature, relative humidity and wind speed into a single
index between 0 and 1 describing how favourable the weather is for adult
mosquito activity. The index is the product of the three response
functions
[`mwi_temperature()`](https://e4warning.github.io/mwi/reference/mwi_responses.md),
[`mwi_humidity()`](https://e4warning.github.io/mwi/reference/mwi_responses.md)
and
[`mwi_wind()`](https://e4warning.github.io/mwi/reference/mwi_responses.md).

## Usage

``` r
mwi(temperature, humidity, wind_speed, units = c("km/h", "m/s"))
```

## Arguments

- temperature:

  Numeric vector of air temperatures in degrees Celsius.

- humidity:

  Numeric vector of relative humidities in percent (0-100).

- wind_speed:

  Numeric vector of wind speeds, in the units given by `units`.

- units:

  Units of `wind_speed`: `"km/h"` (the default) or `"m/s"`.

## Value

A numeric vector of index values in `[0, 1]`, recycled to the length of
the longest input. `NA` in any input gives `NA` in the output.

## Details

Because the three responses are multiplied, any one of them falling
outside its favourable range sets the whole index to zero. The index
reaches 1 only when temperature is between 20 and 25 degrees Celsius,
relative humidity is exactly 95%, and wind speed is at or below the
cut-off.

**The index must be computed before it is averaged, not after.** `mwi()`
is a non-linear function of its inputs, so evaluating it on daily mean
or daily maximum weather gives a different – and empirically much less
useful – answer than evaluating it hourly and then summarising the
result. Daily maxima of humidity and of temperature typically occur many
hours apart, so an index built from them describes an hour that never
happened. Use
[`mwi_summarise()`](https://e4warning.github.io/mwi/reference/mwi_summarise.md)
to aggregate in the correct order.

## See also

[`mwi_category()`](https://e4warning.github.io/mwi/reference/mwi_category.md)
to map the index onto its five activity classes,
[`mwi_summarise()`](https://e4warning.github.io/mwi/reference/mwi_summarise.md)
to aggregate hourly values over time, and
[`mwi_fhft()`](https://e4warning.github.io/mwi/reference/mwi_fhft.md)
for the temperature-and-humidity-only variant.

## Examples

``` r
mwi(temperature = 22, humidity = 70, wind_speed = 10)
#> [1] 0.5454545

# Vectorised, with recycling
mwi(temperature = c(18, 22, 28), humidity = 70, wind_speed = 5)
#> [1] 0.3272727 0.5454545 0.2181818

# Any factor out of range zeroes the index
mwi(temperature = 22, humidity = 30, wind_speed = 5)
#> [1] 0
mwi(temperature = 22, humidity = 70, wind_speed = 30)
#> [1] 0
```
