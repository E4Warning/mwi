#' Weather response functions
#'
#' The three functions from which the Mosquito Weather Index is built. Each maps
#' one weather variable onto a suitability multiplier in `[0, 1]`, where 0 means
#' the variable is outside the range in which adult mosquitoes are taken to be
#' active and 1 means it is in the most favourable part of that range.
#'
#' @details
#' `mwi_temperature()` is a trapezoid: zero at or below 15 degrees Celsius,
#' rising linearly to one at 20, flat between 20 and 25, falling linearly
#' back to zero at 30, and zero above 30.
#'
#' `mwi_humidity()` rises linearly from zero at 40% relative humidity to one at
#' 95%, and is zero outside that band. Note that the drop above 95% is a step,
#' not a taper: 95% gives 1 and 95.1% gives 0. This is intentional and matches
#' the operational definition of the index.
#'
#' `mwi_wind()` is a cut-off rather than a gradient: one at or below
#' 6 m/s (21.6 km/h) and zero above it.
#'
#' All three are vectorised and propagate `NA`.
#'
#' Because a response of zero silences the whole index, inputs in the wrong
#' units fail quietly: temperatures in Kelvin or humidity as a proportion would
#' give an index of zero everywhere. The functions therefore warn when given
#' temperatures above 100, humidities that all lie between 0 and 1, or negative
#' wind speeds (a sign that a wind vector component was passed instead of a
#' speed, which would make every hour look calm).
#'
#' @param temperature Numeric vector of air temperatures in degrees Celsius.
#' @param humidity Numeric vector of relative humidities in percent (0-100).
#' @param wind_speed Numeric vector of wind speeds, in the units given by
#'   `units`.
#' @param units Units of `wind_speed`: `"km/h"` (the default) or `"m/s"`.
#'
#' @return A numeric vector the same length as the input, with values in
#'   `[0, 1]`.
#'
#' @references
#' Developed under the LIFE CONOPS project (LIFE12 ENV/GR/000466) by the Benaki
#' Phytopathological Institute and the National Observatory of Athens.
#'
#' @examples
#' mwi_temperature(c(10, 15, 17.5, 22, 27.5, 30, 35))
#' mwi_humidity(c(30, 40, 67.5, 95, 96))
#' mwi_wind(c(10, 21.6, 25))
#' mwi_wind(c(3, 6, 8), units = "m/s")
#'
#' @name mwi_responses
NULL


#' @rdname mwi_responses
#' @export
mwi_temperature <- function(temperature) {
  check_numeric(temperature, "temperature")

  out <- rep(NA_real_, length(temperature))
  ok <- !is.na(temperature)
  t <- temperature[ok]
  if (any(t > 100)) {
    warning("`temperature` contains values above 100, which are not plausible ",
            "air temperatures in degrees Celsius. Convert Kelvin with ",
            "celsius_from_kelvin().", call. = FALSE)
  }

  out[ok] <- ifelse(
    t <= 15 | t > 30,
    0,
    ifelse(
      t <= 20,
      0.2 * t - 3,
      ifelse(t <= 25, 1, -0.2 * t + 6)
    )
  )
  out
}


#' @rdname mwi_responses
#' @export
mwi_humidity <- function(humidity) {
  check_numeric(humidity, "humidity")

  out <- rep(NA_real_, length(humidity))
  ok <- !is.na(humidity)
  h <- humidity[ok]
  if (length(h) > 0L && all(h <= 1) && any(h > 0)) {
    warning("All `humidity` values are between 0 and 1. Relative humidity ",
            "must be in percent (0-100), not a proportion.", call. = FALSE)
  }

  # Written as h / 55 - 40 / 55, not the algebraically equal (h - 40) / 55,
  # because that is the floating-point expression the evaluation study's
  # pipeline used. The two differ in the last bit for about 60% of observed
  # humidities, and MCMC amplifies bit-level differences in covariates into
  # visibly different posterior summaries, so only the identical expression
  # lets the replication package reproduce the published numbers exactly.
  # Both are exact at the cut-offs: 0 at 40% and 1 at 95%.
  out[ok] <- ifelse(h < 40 | h > 95, 0, h / 55 - 40 / 55)
  out
}


#' @rdname mwi_responses
#' @export
mwi_wind <- function(wind_speed, units = c("km/h", "m/s")) {
  check_numeric(wind_speed, "wind_speed")
  units <- match.arg(units)

  kmh <- if (units == "m/s") wind_speed * 3.6 else wind_speed

  out <- rep(NA_real_, length(kmh))
  ok <- !is.na(kmh)
  if (any(kmh[ok] < 0)) {
    warning("`wind_speed` contains negative values. Supply a speed, not a ",
            "vector component (see wind_speed_from_components()).",
            call. = FALSE)
  }
  out[ok] <- as.numeric(kmh[ok] <= mwi_wind_threshold())
  out
}


#' Wind cut-off used by the index
#'
#' The wind speed above which the index is forced to zero, exposed as a function
#' so that the constant is stated in exactly one place.
#'
#' @param units Units in which to return the threshold: `"km/h"` (the default)
#'   or `"m/s"`.
#' @return A length-one numeric vector.
#' @examples
#' mwi_wind_threshold()
#' mwi_wind_threshold("m/s")
#' @export
mwi_wind_threshold <- function(units = c("km/h", "m/s")) {
  units <- match.arg(units)
  if (units == "m/s") 6 else 6 * 3.6
}
