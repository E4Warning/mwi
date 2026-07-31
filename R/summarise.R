#' Summarise sub-daily weather into index values, in the correct order
#'
#' Computes the Mosquito Weather Index at the resolution of the supplied
#' observations and only then summarises it within each group. This is the order
#' the index requires, and getting it the wrong way round is the most common way
#' to misuse it.
#'
#' @details
#' The index is a product of non-linear response functions, so it does not
#' commute with averaging:
#' `mwi(mean(temperature), mean(humidity), mean(wind))` is not
#' `mean(mwi(temperature, humidity, wind))`. The discrepancy is severe with
#' daily maxima, because the daily maximum of relative humidity and the daily
#' maximum of temperature usually fall many hours apart, so an index computed
#' from them describes conditions that never co-occurred.
#'
#' `mwi_summarise()` therefore takes sub-daily observations, evaluates
#' [mwi()] on each one, and reduces the results with `statistic` within each
#' level of `by`.
#' Empirically the maximum is the more informative summary: it captures whether
#' the period contained a window of favourable conditions, rather than how
#' favourable the period was on average.
#'
#' @param temperature Numeric vector of air temperatures in degrees Celsius.
#' @param humidity Numeric vector of relative humidities in percent (0-100).
#' @param wind_speed Numeric vector of wind speeds, in the units given by
#'   `units`.
#' @param by Grouping vector the same length as the weather inputs, typically a
#'   `Date` or a day-of-year. Values are summarised within each unique element.
#'   Use `NULL` to summarise everything into a single value.
#' @param statistic Summary to apply within each group: `"max"` (the default),
#'   `"mean"`, or `"min"`.
#' @param units Units of `wind_speed`: `"km/h"` (the default) or `"m/s"`.
#' @param na.rm Whether to drop missing index values within each group. If
#'   `FALSE` (the default), a group containing any `NA` returns `NA`.
#'
#' @return A data frame with one row per group and columns `by`, `mwi` and `n`
#'   (the number of observations contributing to the group). If `by` is `NULL`,
#'   a one-row data frame with `by = NA`.
#'
#' @seealso [mwi()] for the index itself.
#'
#' @examples
#' # One synthetic day of hourly weather
#' hours <- 0:23
#' temp <- 18 + 8 * sin((hours - 6) / 24 * 2 * pi)
#' rh <- 75 - 15 * sin((hours - 6) / 24 * 2 * pi)
#' wind <- rep(5, 24)
#'
#' mwi_summarise(temp, rh, wind, by = rep("2019-07-15", 24))
#'
#' # The wrong order gives a different answer
#' mwi(max(temp), max(rh), max(wind))
#'
#' @export
mwi_summarise <- function(temperature, humidity, wind_speed, by = NULL,
                          statistic = c("max", "mean", "min"),
                          units = c("km/h", "m/s"), na.rm = FALSE) {
  statistic <- match.arg(statistic)
  units <- match.arg(units)

  values <- mwi(temperature, humidity, wind_speed, units = units)

  if (is.null(by)) {
    # A single group covering everything. Note that split() silently drops NA
    # groups, so an all-NA `by` cannot be used to stand in for "no grouping".
    groups <- list(values)
    keys <- NA
  } else {
    if (length(by) != length(values)) {
      stop("`by` must be the same length as the weather inputs (",
           length(values), "), not ", length(by), ".", call. = FALSE)
    }
    groups <- split(values, by, drop = FALSE)
    keys <- names(groups)
    if (inherits(by, "Date")) keys <- as.Date(keys)
  }

  f <- switch(statistic, max = max, mean = mean, min = min)

  reduced <- vapply(groups, function(v) {
    if (na.rm) v <- v[!is.na(v)]
    if (length(v) == 0L || anyNA(v)) return(NA_real_)
    as.numeric(f(v))
  }, numeric(1))

  counts <- vapply(groups, function(v) sum(!is.na(v)), integer(1))

  out <- data.frame(by = keys, mwi = unname(reduced), n = unname(counts),
                    stringsAsFactors = FALSE)
  rownames(out) <- NULL
  out
}
