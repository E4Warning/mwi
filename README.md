
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mwi

<!-- badges: start -->

[![R-CMD-check](https://github.com/E4Warning/mwi/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/E4Warning/mwi/actions/workflows/R-CMD-check.yaml) [![DOI](https://zenodo.org/badge/1313906635.svg)](https://doi.org/10.5281/zenodo.22101143)
<!-- badges: end -->

The Mosquito Weather Index (MWI) combines air temperature, relative
humidity and wind speed into a single number between 0 and 1 describing
how favourable the weather is for adult mosquito activity, and maps that
number onto five ordered activity classes. It was developed by the
Benaki Phytopathological Institute and the National Observatory of
Athens under the LIFE CONOPS project (LIFE12 ENV/GR/000466) and has been
published operationally on [meteo.gr](https://meteo.gr) since June 2014.

This package implements the index, the three response functions it is
built from, its activity classes, and the unit conversions needed to
feed it from common weather products. It has no dependencies beyond base
R.

Full documentation, including a worked introduction, is at
<https://e4warning.github.io/mwi/>.

## Installation

``` r
# install.packages("pak")
pak::pak("E4Warning/mwi")
```

## Usage

``` r
library(mwi)

mwi(temperature = 22, humidity = 70, wind_speed = 10)
#> [1] 0.5454545
```

The index is a product of three responses, so any one variable falling
outside its favourable range sets the whole index to zero:

``` r
mwi(temperature = 22, humidity = 30, wind_speed = 10) # too dry
#> [1] 0
mwi(temperature = 35, humidity = 70, wind_speed = 10) # too hot
#> [1] 0
mwi(temperature = 22, humidity = 70, wind_speed = 30) # too windy
#> [1] 0
```

The individual responses are available on their own:

``` r
mwi_temperature(c(10, 17.5, 22, 27.5, 32))
#> [1] 0.0 0.5 1.0 0.5 0.0
mwi_humidity(c(30, 40, 67.5, 95))
#> [1] 0.0 0.0 0.5 1.0
mwi_wind(c(10, 21.6, 25))
#> [1] 1 1 0
```

Continuous values map onto the five classes used for public
communication:

``` r
x <- c(0, 0.2, 0.5, 0.9, 1)
data.frame(mwi = x, class = mwi_category(x))
#>   mwi              class
#> 1 0.0        No activity
#> 2 0.2       Low activity
#> 3 0.5  Moderate activity
#> 4 0.9      High activity
#> 5 1.0 Very high activity
```

## Computing the index over time

**The index must be computed before it is averaged, not after.** Because
`mwi()` is non-linear, evaluating it on daily summaries of each weather
variable is not the same as evaluating it hourly and then summarising
the result — and it is much less useful. Daily maxima of temperature and
of humidity typically occur many hours apart, so an index built from
them describes an hour that never happened.

`mwi_summarise()` does it in the right order:

``` r
hours <- 0:23
temp <- 18 + 8 * sin((hours - 6) / 24 * 2 * pi)
rh <- 75 - 15 * sin((hours - 6) / 24 * 2 * pi)
wind <- rep(5, 24)

# Right: index each hour, then take the daily maximum
mwi_summarise(temp, rh, wind, by = rep("2019-07-15", 24))
#>           by       mwi  n
#> 1 2019-07-15 0.5657766 24

# Wrong: summarise the weather first, then index
mwi(max(temp), max(rh), max(wind))
#> [1] 0.7272727
```

## Working from reanalysis output

Products such as ERA5-Land distribute temperatures in Kelvin, humidity
as a dewpoint, and wind as orthogonal components. The conversions are
included:

``` r
temperature <- celsius_from_kelvin(295.15)
dewpoint <- celsius_from_kelvin(288.15)
humidity <- relative_humidity_from_dewpoint(dewpoint, temperature)
wind <- wind_speed_from_components(u = 1.2, v = -0.8)

mwi(temperature, humidity, wind, units = "m/s")
#> [1] 0.4455658
```

## Citation

If you use this package, please cite the evaluation study alongside it.
See `citation("mwi")`.

## License

GPL (\>= 3). The index itself was developed by the Benaki
Phytopathological Institute and the National Observatory of Athens under
the LIFE CONOPS project (LIFE12 ENV/GR/000466).
