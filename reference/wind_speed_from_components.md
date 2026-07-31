# Wind speed from eastward and northward components

Reanalysis products distribute wind as orthogonal components rather than
as a scalar speed. This returns the magnitude, in whatever units the
components are supplied in.

## Usage

``` r
wind_speed_from_components(u, v)
```

## Arguments

- u:

  Numeric vector of eastward (zonal) wind components.

- v:

  Numeric vector of northward (meridional) wind components.

## Value

A numeric vector of wind speeds in the units of `u` and `v`.

## Examples

``` r
wind_speed_from_components(u = 3, v = 4)
#> [1] 5

# ERA5-Land gives components in m/s
w <- wind_speed_from_components(u = c(1.2, -3.4), v = c(0.8, 2.1))
mwi_wind(w, units = "m/s")
#> [1] 1 1
```
