# mwi (development version)

## Bug fixes

* `mwi_summarise()` no longer silently drops observations whose `by` value is
  `NA`; they now form a group of their own, reported last. The `by` column of
  the result keeps the class of the `by` argument (numeric, `POSIXct` and
  factor groups were previously returned as character), and grouping matches
  on underlying values, so distinct times that print alike, such as the
  repeated hour when clocks go back, are no longer merged.
* `mwi_category()` compares values with the class boundaries using a tolerance
  of `1e-9`, so that values differing from a boundary only by floating-point
  rounding are classified correctly. Previously `mwi(18.3, 95, 5)`, which is
  exactly 0.66, was classed as "High activity" rather than "Moderate activity".
  No index value in the evaluation study lies within the tolerance of a
  boundary, so no published result is affected.
* `relative_humidity_from_dewpoint()` now defaults to the Magnus coefficients
  given by the Vaisala reference its documentation cites (m = 7.591386,
  Tn = 240.7263); the previous defaults (7.591398, 240.726) contained a
  transcription error. Over the study's ERA5-Land data the difference is at
  most 0.0001 percentage points of relative humidity. The evaluation pipeline
  passes its coefficients explicitly, so its results are unchanged.
* `citation("mwi")` now gives the evaluation article's correct title and full
  author list.
* `mwi_humidity()` now evaluates the humidity ramp as `h / 55 - 40 / 55`, the
  exact floating-point expression used by the evaluation study's pipeline,
  instead of the algebraically equal `(h - 40) / 55`. The two differ only in
  the last bit, but for about 60% of observed humidities, and MCMC amplifies
  such differences into visibly different posterior summaries; with the
  identical expression the replication package can reproduce the published
  numbers exactly.

## Improvements

* `mwi_temperature()`, `mwi_humidity()` and `mwi_wind()`, and so `mwi()`, warn
  when inputs look like the wrong units: temperatures above 100 (Kelvin),
  humidities that all lie between 0 and 1 (a proportion rather than percent),
  or negative wind speeds (a vector component rather than a speed). These
  would otherwise silently give an index of zero, or for wind, one.
* `relative_humidity_from_dewpoint()` and `wind_speed_from_components()`
  enforce the same recycling rule as `mwi()`: arguments must have the same
  length or length 1.
* `mwi_category()` gives an informative error for duplicated `labels`.

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
