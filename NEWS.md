# mwi 0.1.0

Initial public release, accompanying the article *Evaluating the Mosquito
Weather Index: A simple tool for predicting and communicating mosquito
activity* (submitted).

* `mwi()` implements the Mosquito Weather Index as operationally defined under
  the LIFE CONOPS project, with its three weather-response functions
  (`mwi_temperature()`, `mwi_humidity()`, `mwi_wind()`) and the
  temperature-and-humidity-only variant `mwi_fhft()`.
* `mwi_category()` maps index values onto the five operational activity
  classes; `mwi_activity_levels()` returns the labels.
* `mwi_summarise()` aggregates sub-daily weather in the order the index
  requires: computed at sub-daily resolution first, then summarised.
* Conversions for reanalysis inputs: `relative_humidity_from_dewpoint()`
  (Magnus approximation), `wind_speed_from_components()`,
  `celsius_from_kelvin()`.
* Validated against the article's analysis pipeline: the test suite includes
  314 hourly ERA5-Land observations from the study with pipeline-computed
  reference values, stratified across every regime of every response function.
