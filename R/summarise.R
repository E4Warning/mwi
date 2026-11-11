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
#' In the evaluation study, the daily maximum predicted adult trap counts
#' better than the daily mean, consistent with catches responding to whether
#' the day contained a window of favourable conditions rather than to how
#' favourable it was on average. That is one city and one trap type, so treat
#' the default as a sensible starting point rather than a general rule.
#'
#' @param temperature Numeric vector of air temperatures in degrees Celsius.
#' @param humidity Numeric vector of relative humidities in percent (0-100).
#' @param wind_speed Numeric vector of wind speeds, in the units given by
#'   `units`.
#' @param by Grouping vector the same length as the weather inputs, typically a
#'   `Date` or a day-of-year. Values are summarised within each unique element.
#'   Missing values of `by` form a group of their own, reported last, so no
#'   observation is silently dropped. For a factor, every level is reported,
#'   including levels with no observations. Use `NULL` to summarise everything
#'   into a single value.
#' @param statistic Summary to apply within each group: `"max"` (the default),
#'   `"mean"`, or `"min"`.
#' @param units Units of `wind_speed`: `"km/h"` (the default) or `"m/s"`.
#' @param na.rm Whether to drop missing index values within each group. If
#'   `FALSE` (the default), a group containing any `NA` returns `NA`.
#'
#' @return A data frame with one row per group, sorted by group, and columns
#'   `by` (the group, with the same class as the `by` argument, so the result
#'   can be joined back onto the data it came from), `mwi`, and `n` (the number
#'   of non-missing index values in the group). If `by` is `NULL`, a one-row
#'   data frame with `by = NA`.
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
    keys <- NA
    group <- rep_len(1L, length(values))
  } else {
    if (length(by) != length(values)) {
      stop("`by` must be the same length as the weather inputs (",
           length(values), "), not ", length(by), ".", call. = FALSE)
    }
    if (inherits(by, "POSIXlt")) by <- as.POSIXct(by)
    keys <- group_keys(by)
    # Match on the underlying values rather than their printed form, which can
    # coincide for distinct times (e.g. the repeated hour when clocks go back).
    group <- match(unclass(by), unclass(keys))
  }

  groups <- split(values, factor(group, levels = seq_along(keys)))
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


#' Sorted unique values of a grouping vector
#'
#' Keeps the class of `by` (Date, POSIXct, numeric, factor, ...), places `NA`
#' last when present, and for a factor returns every level, including unused
#' ones, so that empty groups are reported rather than dropped.
#'
#' @param by Grouping vector.
#' @return A vector of the same class as `by`.
#' @noRd
group_keys <- function(by) {
  if (is.factor(by)) {
    lv <- levels(by)
    return(factor(c(lv, if (anyNA(by)) NA), levels = lv,
                  ordered = is.ordered(by)))
  }
  sort(unique(by), na.last = TRUE)
}
