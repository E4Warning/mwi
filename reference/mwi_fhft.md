# Temperature-and-humidity variant of the index (FHFT)

The Mosquito Weather Index with the wind term omitted, that is the
product of
[`mwi_humidity()`](https://e4warning.github.io/mwi/reference/mwi_responses.md)
and
[`mwi_temperature()`](https://e4warning.github.io/mwi/reference/mwi_responses.md)
only. Useful when no wind observations are available, for example when
working with temperature and humidity loggers.

## Usage

``` r
mwi_fhft(temperature, humidity)
```

## Arguments

- temperature:

  Numeric vector of air temperatures in degrees Celsius.

- humidity:

  Numeric vector of relative humidities in percent (0-100).

## Value

A numeric vector of index values in `[0, 1]`.

## Examples

``` r
mwi_fhft(temperature = 22, humidity = 70)
#> [1] 0.5454545

# Equal to mwi() whenever wind is below the cut-off
identical(
  mwi_fhft(22, 70),
  mwi(22, 70, wind_speed = 0)
)
#> [1] TRUE
```
