#' Derive relative humidity from dewpoint and air temperature
#'
#' Uses the Magnus approximation, which is accurate over roughly -20 to 50
#' degrees Celsius. This is the conversion needed to obtain the humidity
#' input of [mwi()] from reanalysis products such as ERA5-Land, which
#' distribute dewpoint rather than relative humidity.
#'
#' @details
#' The result is not capped at 100%. Reanalysis dewpoint occasionally exceeds
#' air temperature slightly, giving values just above 100; these are returned
#' as they are, so that such cases remain visible. The index is unaffected,
#' because [mwi_humidity()] treats anything above 95% as unfavourable.
#'
#' @param dewpoint Numeric vector of dewpoint temperatures in degrees Celsius.
#' @param temperature Numeric vector of air temperatures in degrees Celsius.
#' @param m,tn Magnus coefficients. The defaults are Vaisala's values for water
#'   vapour over liquid water between -20 and +50 degrees Celsius (Table 1 of the
#'   reference below).
#'
#' @return A numeric vector of relative humidities in percent. Arguments must
#'   have the same length or length 1.
#'
#' @references
#' Vaisala (2013). Humidity Conversion Formulas: Calculation formulas for
#' humidity. Technical report B210973EN-F.
#'
#' @examples
#' relative_humidity_from_dewpoint(dewpoint = 15, temperature = 22)
#'
#' # Dewpoint equal to air temperature is saturation
#' relative_humidity_from_dewpoint(20, 20)
#'
#' @export
relative_humidity_from_dewpoint <- function(dewpoint, temperature,
                                           m = 7.591386, tn = 240.7263) {
  check_numeric(dewpoint, "dewpoint")
  check_numeric(temperature, "temperature")
  recycle_length(dewpoint = dewpoint, temperature = temperature)

  100 * 10^(m * (
    (dewpoint / (dewpoint + tn)) - (temperature / (temperature + tn))
  ))
}


#' Wind speed from eastward and northward components
#'
#' Reanalysis products distribute wind as orthogonal components rather than as a
#' scalar speed. This returns the magnitude, in whatever units the
#' components are supplied in.
#'
#' @param u Numeric vector of eastward (zonal) wind components.
#' @param v Numeric vector of northward (meridional) wind components.
#'
#' @return A numeric vector of wind speeds in the units of `u` and `v`.
#'   Arguments must have the same length or length 1.
#'
#' @examples
#' wind_speed_from_components(u = 3, v = 4)
#'
#' # ERA5-Land gives components in m/s
#' w <- wind_speed_from_components(u = c(1.2, -3.4), v = c(0.8, 2.1))
#' mwi_wind(w, units = "m/s")
#'
#' @export
wind_speed_from_components <- function(u, v) {
  check_numeric(u, "u")
  check_numeric(v, "v")
  recycle_length(u = u, v = v)
  sqrt(u^2 + v^2)
}


#' Convert Kelvin to degrees Celsius
#'
#' @param kelvin Numeric vector of temperatures in Kelvin.
#' @return A numeric vector of temperatures in degrees Celsius.
#' @examples
#' celsius_from_kelvin(c(273.15, 295.15))
#' @export
celsius_from_kelvin <- function(kelvin) {
  check_numeric(kelvin, "kelvin")
  kelvin - 273.15
}
