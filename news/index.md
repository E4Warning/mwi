# Changelog

## mwi 0.1.0

Initial public release, accompanying the article *Evaluating the
Mosquito Weather Index: A simple tool for predicting and communicating
mosquito activity* (submitted).

- [`mwi()`](https://e4warning.github.io/mwi/reference/mwi.md) implements
  the Mosquito Weather Index as operationally defined under the LIFE
  CONOPS project, with its three weather-response functions
  ([`mwi_temperature()`](https://e4warning.github.io/mwi/reference/mwi_responses.md),
  [`mwi_humidity()`](https://e4warning.github.io/mwi/reference/mwi_responses.md),
  [`mwi_wind()`](https://e4warning.github.io/mwi/reference/mwi_responses.md))
  and the temperature-and-humidity-only variant
  [`mwi_fhft()`](https://e4warning.github.io/mwi/reference/mwi_fhft.md).
- [`mwi_category()`](https://e4warning.github.io/mwi/reference/mwi_category.md)
  maps index values onto the five operational activity classes;
  [`mwi_activity_levels()`](https://e4warning.github.io/mwi/reference/mwi_activity_levels.md)
  returns the labels.
- [`mwi_summarise()`](https://e4warning.github.io/mwi/reference/mwi_summarise.md)
  aggregates sub-daily weather in the order the index requires: computed
  at sub-daily resolution first, then summarised.
- Conversions for reanalysis inputs:
  [`relative_humidity_from_dewpoint()`](https://e4warning.github.io/mwi/reference/relative_humidity_from_dewpoint.md)
  (Magnus approximation),
  [`wind_speed_from_components()`](https://e4warning.github.io/mwi/reference/wind_speed_from_components.md),
  [`celsius_from_kelvin()`](https://e4warning.github.io/mwi/reference/celsius_from_kelvin.md).
- Validated against the article’s analysis pipeline: the test suite
  includes 314 hourly ERA5-Land observations from the study with
  pipeline-computed reference values, stratified across every regime of
  every response function.
