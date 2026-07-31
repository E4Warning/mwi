#' Map index values onto the five activity classes
#'
#' Converts continuous index values into the five ordered classes used to
#' communicate the index to the public and to mosquito-control stakeholders.
#'
#' @details
#' The class boundaries are
#'
#' | Index value          | Class              |
#' |----------------------|--------------------|
#' | `= 0`                | No activity        |
#' | `> 0` and `<= 0.33`  | Low activity       |
#' | `> 0.33` and `<= 0.66` | Moderate activity |
#' | `> 0.66` and `< 1`   | High activity      |
#' | `= 1`                | Very high activity |
#'
#' Note that "very high activity" corresponds to the single value 1, which the
#' index attains only when relative humidity is exactly 95% and the other two
#' variables are in their optimal ranges (see [mwi()]). Reported humidity is
#' usually rounded to whole percentage points, so this occurs in practice,
#' but it will be rare in continuous data such as reanalysis output.
#'
#' @param x Numeric vector of index values in `[0, 1]`, for example the
#'   result of [mwi()].
#' @param labels Character vector of five class labels, ordered from least to
#'   most activity. Defaults to [mwi_activity_levels()]; supply your own to
#'   translate them.
#'
#' @return An ordered factor with five levels.
#'
#' @examples
#' mwi_category(c(0, 0.2, 0.5, 0.9, 1))
#'
#' # Order is respected, so classes can be compared
#' mwi_category(0.9) > mwi_category(0.2)
#'
#' # Supply your own labels
#' labs <- c("none", "low", "moderate", "high", "very high")
#' mwi_category(c(0, 1), labels = labs)
#'
#' @export
mwi_category <- function(x, labels = mwi_activity_levels()) {
  check_numeric(x, "x")
  if (length(labels) != 5L) {
    stop("`labels` must have exactly 5 elements, not ", length(labels), ".",
         call. = FALSE)
  }

  bad <- !is.na(x) & (x < 0 | x > 1)
  if (any(bad)) {
    stop("`x` must contain index values in [0, 1]; found ", sum(bad),
         " value(s) outside that range.", call. = FALSE)
  }

  out <- rep(NA_character_, length(x))
  ok <- !is.na(x)
  v <- x[ok]

  out[ok] <- ifelse(
    v == 0, labels[1],
    ifelse(v <= 0.33, labels[2],
      ifelse(v <= 0.66, labels[3],
        ifelse(v < 1, labels[4], labels[5])
      )
    )
  )

  factor(out, levels = labels, ordered = TRUE)
}


#' Activity class labels
#'
#' The five ordered class labels used by [mwi_category()], from least to most
#' activity.
#'
#' @return A character vector of length five.
#' @examples
#' mwi_activity_levels()
#' @export
mwi_activity_levels <- function() {
  c(
    "No activity",
    "Low activity",
    "Moderate activity",
    "High activity",
    "Very high activity"
  )
}
