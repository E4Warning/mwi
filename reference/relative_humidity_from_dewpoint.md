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
  m = 7.591386,
  tn = 240.7263
)
```

## Arguments

- dewpoint:

  Numeric vector of dewpoint temperatures in degrees Celsius.

- temperature:

  Numeric vector of air temperatures in degrees Celsius.

- m, tn:

  Magnus coefficients. The defaults are Vaisala's values for water
  vapour over liquid water between -20 and +50 degrees Celsius (Table 1
  of the reference below).

## Value

A numeric vector of relative humidities in percent. Arguments must have
the same length or length 1.

## Details

The result is not capped at 100%. Reanalysis dewpoint occasionally
exceeds air temperature slightly, giving values just above 100; these
are returned as they are, so that such cases remain visible. The index
is unaffected, because
[`mwi_humidity()`](https://e4warning.github.io/mwi/reference/mwi_responses.md)
treats anything above 95% as unfavourable.

## References

Vaisala (2013). Humidity Conversion Formulas: Calculation formulas for
humidity. Technical report B210973EN-F.

## Examples

``` r
relative_humidity_from_dewpoint(dewpoint = 15, temperature = 22)
#> [1] 64.50619

# Dewpoint equal to air temperature is saturation
relative_humidity_from_dewpoint(20, 20)
#> [1] 100
```
