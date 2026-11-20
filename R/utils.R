#' Validate a numeric argument
#'
#' @param x Value to check.
#' @param arg Argument name, used in the error message.
#' @return `x`, invisibly.
#' @noRd
check_numeric <- function(x, arg) {
  # Accept numbers, and also a vector that is entirely NA (a bare NA is of type
  # logical in R). Anything else stops with a message that names the argument.
  if (!is.numeric(x) && !all(is.na(x))) {
    stop("`", arg, "` must be numeric, not ", class(x)[1], ".", call. = FALSE)
  }
  # Return the input without printing it.
  invisible(x)
}


#' Common length for recyclable arguments
#'
#' Returns the length the arguments recycle to, erroring if they are not
#' compatible. Only length-one and full-length vectors are allowed, which is
#' stricter than base R recycling and avoids silent partial-recycling bugs.
#'
#' @param ... Named vectors.
#' @return A single integer.
#' @noRd
recycle_length <- function(...) {
  # The arguments and their lengths.
  args <- list(...)
  lengths <- vapply(args, length, integer(1))

  # If any argument is empty, the common length is zero (the result will be
  # empty).
  if (any(lengths == 0L)) return(0L)

  # Otherwise the common length is the longest length,
  n <- max(lengths)
  # and every argument must have that length or length 1.
  bad <- lengths != 1L & lengths != n
  # If not, stop and name the arguments at fault with their lengths.
  if (any(bad)) {
    stop(
      "Arguments must have the same length or length 1. Got ",
      paste0("`", names(args)[bad], "` (", lengths[bad], ")", collapse = ", "),
      " against a common length of ", n, ".",
      call. = FALSE
    )
  }
  n
}
