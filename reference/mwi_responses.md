# Weather response functions

The three functions from which the Mosquito Weather Index is built. Each
maps one weather variable onto a suitability multiplier in `[0, 1]`,
where 0 means the variable is outside the range in which adult
mosquitoes are taken to be active and 1 means it is in the most
favourable part of that range.

## Usage

``` r
mwi_temperature(temperature)

mwi_humidity(humidity)

mwi_wind(wind_speed, units = c("km/h", "m/s"))
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

A numeric vector the same length as the input, with values in `[0, 1]`.

## Details

`mwi_temperature()` is a trapezoid: zero at or below 15 degrees Celsius,
rising linearly to one at 20, flat between 20 and 25, falling linearly
back to zero at 30, and zero above 30.

`mwi_humidity()` rises linearly from zero at 40% relative humidity to
one at 95%, and is zero outside that band. Note that the drop above 95%
is a step, not a taper: 95% gives 1 and 95.1% gives 0. This is
intentional and matches the operational definition of the index.

`mwi_wind()` is a cut-off rather than a gradient: one at or below 6 m/s
(21.6 km/h) and zero above it.

All three are vectorised and propagate `NA`.

## References

Developed under the LIFE CONOPS project (LIFE12 ENV/GR/000466) by the
Benaki Phytopathological Institute and the National Observatory of
Athens.

## Examples

``` r
mwi_temperature(c(10, 15, 17.5, 22, 27.5, 30, 35))
#> [1] 0.0 0.0 0.5 1.0 0.5 0.0 0.0
mwi_humidity(c(30, 40, 67.5, 95, 96))
#> [1] 0.0 0.0 0.5 1.0 0.0
mwi_wind(c(10, 21.6, 25))
#> [1] 1 1 0
mwi_wind(c(3, 6, 8), units = "m/s")
#> [1] 1 1 0
```
