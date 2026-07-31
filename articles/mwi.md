# Getting started with the Mosquito Weather Index

``` r

library(mwi)
```

## What the index is

The Mosquito Weather Index reduces three weather variables to one number
in `[0, 1]`. It is the product of three response functions, each of
which returns a suitability multiplier for one variable:

``` r

mwi_temperature(22)
#> [1] 1
mwi_humidity(70)
#> [1] 0.5454545
mwi_wind(10)
#> [1] 1

mwi_temperature(22) * mwi_humidity(70) * mwi_wind(10)
#> [1] 0.5454545
mwi(temperature = 22, humidity = 70, wind_speed = 10)
#> [1] 0.5454545
```

The shapes are worth knowing, because they explain most of the index’s
behaviour.

[`mwi_temperature()`](https://e4warning.github.io/mwi/reference/mwi_responses.md)
is a trapezoid, flat and maximal from 20 to 25 °C and zero outside 15–30
°C:

``` r

t <- seq(10, 35, by = 5)
data.frame(temperature = t, response = mwi_temperature(t))
#>   temperature response
#> 1          10        0
#> 2          15        0
#> 3          20        1
#> 4          25        1
#> 5          30        0
#> 6          35        0
```

[`mwi_humidity()`](https://e4warning.github.io/mwi/reference/mwi_responses.md)
ramps linearly from 40% to 95%, then drops to zero as a step:

``` r

h <- c(35, 40, 60, 80, 95, 96)
data.frame(humidity = h, response = mwi_humidity(h))
#>   humidity  response
#> 1       35 0.0000000
#> 2       40 0.0000000
#> 3       60 0.3636364
#> 4       80 0.7272727
#> 5       95 1.0000000
#> 6       96 0.0000000
```

That step at 95% is deliberate, not an artefact. It has a practical
consequence: the index reaches 1 only when humidity is *exactly* 95%, so
the top “very high activity” class is attained on rounded observational
data but almost never on continuous data such as reanalysis output.

[`mwi_wind()`](https://e4warning.github.io/mwi/reference/mwi_responses.md)
is a switch rather than a gradient:

``` r

mwi_wind_threshold()
#> [1] 21.6
mwi_wind(c(21.5, 21.6, 21.7))
#> [1] 1 1 0
```

Because the three responses are multiplied, any one of them hitting zero
takes the whole index with it. Wind and humidity are therefore best
thought of as gates, and temperature as the thing that grades the
result.

## Compute first, aggregate second

This is the part that most often goes wrong.

[`mwi()`](https://e4warning.github.io/mwi/reference/mwi.md) is
non-linear, so it does not commute with averaging. If you have hourly
weather and you want a daily index, you must evaluate the index hourly
and then summarise the resulting index values. Summarising the weather
first and then indexing gives a different answer.

The problem is worst with daily maxima, because the daily maximum of
relative humidity and the daily maximum of temperature fall at opposite
ends of the day — humidity peaks in the small hours, temperature in
mid-afternoon. Combining them describes an hour that never occurred.

``` r

hours <- 0:23
temperature <- 18 + 8 * sin((hours - 6) / 24 * 2 * pi)
humidity <- 75 - 15 * sin((hours - 6) / 24 * 2 * pi)
wind_speed <- rep(5, 24)

# Note the phase difference: they peak twelve hours apart
c(warmest_hour = which.max(temperature) - 1,
  most_humid_hour = which.max(humidity) - 1)
#>    warmest_hour most_humid_hour 
#>              12               0
```

``` r

# Right: index each hour, then reduce
mwi_summarise(temperature, humidity, wind_speed,
              by = rep("2019-07-15", 24), statistic = "max")
#>           by       mwi  n
#> 1 2019-07-15 0.5657766 24

# Wrong: reduce the weather, then index
mwi(max(temperature), max(humidity), max(wind_speed))
#> [1] 0.7272727
```

[`mwi_summarise()`](https://e4warning.github.io/mwi/reference/mwi_summarise.md)
enforces the correct order. Group with `by` to get one row per day:

``` r

two_days <- rep(as.Date(c("2019-07-15", "2019-07-16")), each = 24)
mwi_summarise(rep(temperature, 2), rep(humidity, 2), rep(wind_speed, 2),
              by = two_days)
#>           by       mwi  n
#> 1 2019-07-15 0.5657766 24
#> 2 2019-07-16 0.5657766 24
```

### Maximum or mean?

Both are available through `statistic`. In the evaluation study
accompanying this package, the daily *maximum* consistently predicted
adult trap counts better than the daily mean, which is consistent with
catch responding to whether the day contained a window of favourable
conditions rather than to how favourable the day was on average.

``` r

by <- rep("2019-07-15", 24)
rbind(
  mwi_summarise(temperature, humidity, wind_speed, by, statistic = "max"),
  mwi_summarise(temperature, humidity, wind_speed, by, statistic = "mean"),
  mwi_summarise(temperature, humidity, wind_speed, by, statistic = "min")
)
#>           by       mwi  n
#> 1 2019-07-15 0.5657766 24
#> 2 2019-07-15 0.2405692 24
#> 3 2019-07-15 0.0000000 24
```

## Activity classes

For communication the continuous index is reduced to five ordered
classes:

``` r

x <- c(0, 0.15, 0.5, 0.85, 1)
data.frame(mwi = x, class = mwi_category(x))
#>    mwi              class
#> 1 0.00        No activity
#> 2 0.15       Low activity
#> 3 0.50  Moderate activity
#> 4 0.85      High activity
#> 5 1.00 Very high activity
```

The result is an ordered factor, so it can be compared and sorted:

``` r

mwi_category(0.85) > mwi_category(0.15)
#> [1] TRUE
```

Pass `labels` to translate them:

``` r

greek <- c("Καμία", "Χαμηλή", "Μέτρια", "Υψηλή", "Πολύ υψηλή")
mwi_category(c(0, 0.5, 1), labels = greek)
#> [1] Καμία      Μέτρια     Πολύ υψηλή
#> Levels: Καμία < Χαμηλή < Μέτρια < Υψηλή < Πολύ υψηλή
```

## Feeding the index from reanalysis data

Gridded products rarely give you the three variables in the form the
index wants. ERA5-Land, for instance, distributes 2 m air temperature
and 2 m dewpoint in Kelvin, and 10 m wind as eastward and northward
components in m/s. The conversions are included:

``` r

t2m <- c(295.15, 299.15, 291.15)
d2m <- c(288.15, 289.15, 287.15)
u10 <- c(1.2, -3.4, 0.5)
v10 <- c(-0.8, 2.1, 1.1)

temperature <- celsius_from_kelvin(t2m)
dewpoint <- celsius_from_kelvin(d2m)
humidity <- relative_humidity_from_dewpoint(dewpoint, temperature)
wind_speed <- wind_speed_from_components(u10, v10)

data.frame(
  temperature = round(temperature, 1),
  humidity = round(humidity, 1),
  wind_ms = round(wind_speed, 1),
  mwi = round(mwi(temperature, humidity, wind_speed, units = "m/s"), 3)
)
#>   temperature humidity wind_ms   mwi
#> 1          22     64.5     1.4 0.446
#> 2          26     54.1     4.0 0.205
#> 3          18     77.5     1.2 0.409
```

## When wind is unavailable

Temperature and humidity loggers do not measure wind.
[`mwi_fhft()`](https://e4warning.github.io/mwi/reference/mwi_fhft.md)
drops the wind term, which is equivalent to assuming wind is always
below the cut-off:

``` r

mwi_fhft(temperature = 22, humidity = 70)
#> [1] 0.5454545
mwi(temperature = 22, humidity = 70, wind_speed = 0)
#> [1] 0.5454545
```

Treat this variant with care. The evaluation study found that
substituting on-site logger readings for gridded reanalysis made the
index a *worse* predictor of trap counts, partly because logger humidity
ran systematically dry and the 40% threshold amplifies that bias.

## Missing values

Every function propagates `NA` rather than guessing:

``` r

mwi(temperature = c(22, NA), humidity = 70, wind_speed = 5)
#> [1] 0.5454545        NA
```

In
[`mwi_summarise()`](https://e4warning.github.io/mwi/reference/mwi_summarise.md),
a group containing any missing index value returns `NA` unless you ask
otherwise:

``` r

gappy_temperature <- 18 + 8 * sin((hours - 6) / 24 * 2 * pi)
gappy_temperature[5] <- NA
gappy_humidity <- 75 - 15 * sin((hours - 6) / 24 * 2 * pi)

mwi_summarise(gappy_temperature, gappy_humidity, rep(5, 24), by)$mwi
#> [1] NA
mwi_summarise(gappy_temperature, gappy_humidity, rep(5, 24), by,
              na.rm = TRUE)$mwi
#> [1] 0.5657766
```

Note that arguments must be the same length or length 1. Partial
recycling is an error rather than a silent surprise:

``` r

mwi(temperature = c(20, 22, 24, 26), humidity = c(60, 70), wind_speed = 5)
#> Error:
#> ! Arguments must have the same length or length 1. Got `humidity` (2) against a common length of 4.
```
