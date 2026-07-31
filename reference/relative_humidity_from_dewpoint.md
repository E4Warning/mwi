# Derive relative humidity from dewpoint and air temperature

Uses the Magnus approximation, which is accurate over roughly -20 to 50
degrees Celsius. This is the conversion needed to obtain the humidity
input of [`mwi()`](https://e4warning.github.io/mwi/reference/mwi.md)
from reanalysis products such as ERA5-Land, which distribute dewpoint
rather than relative humidity.

## Usage

``` r
relative_humidity_from_dewpoint(
  dewpoint,
  temperature,
  m = 7.591398,
  tn = 240.726
)
```

## Arguments

- dewpoint:

  Numeric vector of dewpoint temperatures in degrees Celsius.

- temperature:

  Numeric vector of air temperatures in degrees Celsius.

- m, tn:

  Magnus coefficients. The defaults are the values for water vapour over
  liquid water.

## Value

A numeric vector of relative humidities in percent.

## References

Vaisala (2013). Humidity Conversion Formulas: Calculation formulas for
humidity. Technical report B210973EN-F.

## Examples

``` r
relative_humidity_from_dewpoint(dewpoint = 15, temperature = 22)
#> [1] 64.50612

# Dewpoint equal to air temperature is saturation
relative_humidity_from_dewpoint(20, 20)
#> [1] 100
```
