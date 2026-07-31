# Package index

## The index

Compute the Mosquito Weather Index and its temperature-and-humidity-only
variant.

- [`mwi()`](https://e4warning.github.io/mwi/reference/mwi.md) : Mosquito
  Weather Index
- [`mwi_fhft()`](https://e4warning.github.io/mwi/reference/mwi_fhft.md)
  : Temperature-and-humidity variant of the index (FHFT)

## Response functions

The three weather responses the index is built from, and the wind
cut-off they share.

- [`mwi_temperature()`](https://e4warning.github.io/mwi/reference/mwi_responses.md)
  [`mwi_humidity()`](https://e4warning.github.io/mwi/reference/mwi_responses.md)
  [`mwi_wind()`](https://e4warning.github.io/mwi/reference/mwi_responses.md)
  : Weather response functions
- [`mwi_wind_threshold()`](https://e4warning.github.io/mwi/reference/mwi_wind_threshold.md)
  : Wind cut-off used by the index

## Aggregating over time

Summarise sub-daily weather into index values in the order the index
requires.

- [`mwi_summarise()`](https://e4warning.github.io/mwi/reference/mwi_summarise.md)
  : Summarise sub-daily weather into index values, in the correct order

## Activity classes

Map continuous index values onto the five ordered classes used for
public communication.

- [`mwi_category()`](https://e4warning.github.io/mwi/reference/mwi_category.md)
  : Map index values onto the five activity classes
- [`mwi_activity_levels()`](https://e4warning.github.io/mwi/reference/mwi_activity_levels.md)
  : Activity class labels

## Unit conversions

Derive the index inputs from the forms in which reanalysis products
distribute them.

- [`relative_humidity_from_dewpoint()`](https://e4warning.github.io/mwi/reference/relative_humidity_from_dewpoint.md)
  : Derive relative humidity from dewpoint and air temperature
- [`wind_speed_from_components()`](https://e4warning.github.io/mwi/reference/wind_speed_from_components.md)
  : Wind speed from eastward and northward components
- [`celsius_from_kelvin()`](https://e4warning.github.io/mwi/reference/celsius_from_kelvin.md)
  : Convert Kelvin to degrees Celsius
