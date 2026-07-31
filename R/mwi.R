#' Mosquito Weather Index
#'
#' Combines air temperature, relative humidity and wind speed into a single
#' index between 0 and 1 describing how favourable the weather is for adult
#' mosquito activity. The index is the product of the three response functions
#' [mwi_temperature()], [mwi_humidity()] and [mwi_wind()].
#'
#' @details
#' Because the three responses are multiplied, any one of them falling outside
#' its favourable range sets the whole index to zero. The index reaches 1 only
#' when temperature is between 20 and 25 degrees Celsius, relative humidity is
#' exactly 95%, and wind speed is at or below the cut-off.
#'
#' **The index must be computed before it is averaged, not after.** `mwi()` is a
#' non-linear function of its inputs, so evaluating it on daily mean or daily
#' maximum weather gives a different -- and empirically much less useful --
#' answer than evaluating it hourly and then summarising the result. Daily
#' maxima of humidity and of temperature typically occur many hours apart, so
#' an index built from them describes an hour that never happened. Use
#' [mwi_summarise()] to aggregate in the correct order.
#'
#' @param temperature Numeric vector of air temperatures in degrees Celsius.
#' @param humidity Numeric vector of relative humidities in percent (0-100).
#' @param wind_speed Numeric vector of wind speeds, in the units given by
#'   `units`.
#' @param units Units of `wind_speed`: `"km/h"` (the default) or `"m/s"`.
#'
#' @return A numeric vector of index values in `[0, 1]`, recycled to the length
#'   of the longest input. `NA` in any input gives `NA` in the output.
#'
#' @seealso [mwi_category()] to map the index onto its five activity classes,
#'   [mwi_summarise()] to aggregate hourly values over time, and [mwi_fhft()]
#'   for the temperature-and-humidity-only variant.
#'
#' @examples
#' mwi(temperature = 22, humidity = 70, wind_speed = 10)
#'
#' # Vectorised, with recycling
#' mwi(temperature = c(18, 22, 28), humidity = 70, wind_speed = 5)
#'
#' # Any factor out of range zeroes the index
#' mwi(temperature = 22, humidity = 30, wind_speed = 5)
#' mwi(temperature = 22, humidity = 70, wind_speed = 30)
#'
#' @export
mwi <- function(temperature, humidity, wind_speed, units = c("km/h", "m/s")) {
  units <- match.arg(units)
  n <- recycle_length(
    temperature = temperature,
    humidity = humidity,
    wind_speed = wind_speed
  )

  mwi_temperature(rep_len(temperature, n)) *
    mwi_humidity(rep_len(humidity, n)) *
    mwi_wind(rep_len(wind_speed, n), units = units)
}


#' Temperature-and-humidity variant of the index (FHFT)
#'
#' The Mosquito Weather Index with the wind term omitted, that is the product of
#' [mwi_humidity()] and [mwi_temperature()] only. Useful when no wind
#' observations are available, for example when working with temperature and
#' humidity loggers.
#'
#' @inheritParams mwi
#'
#' @return A numeric vector of index values in `[0, 1]`.
#'
#' @examples
#' mwi_fhft(temperature = 22, humidity = 70)
#'
#' # Equal to mwi() whenever wind is below the cut-off
#' identical(
#'   mwi_fhft(22, 70),
#'   mwi(22, 70, wind_speed = 0)
#' )
#'
#' @export
mwi_fhft <- function(temperature, humidity) {
  n <- recycle_length(temperature = temperature, humidity = humidity)
  mwi_humidity(rep_len(humidity, n)) * mwi_temperature(rep_len(temperature, n))
}
