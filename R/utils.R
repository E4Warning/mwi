#' Validate a numeric argument
#'
#' @param x Value to check.
#' @param arg Argument name, used in the error message.
#' @return `x`, invisibly.
#' @noRd
check_numeric <- function(x, arg) {
  if (!is.numeric(x) && !all(is.na(x))) {
    stop("`", arg, "` must be numeric, not ", class(x)[1], ".", call. = FALSE)
  }
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
  args <- list(...)
  lengths <- vapply(args, length, integer(1))

  if (any(lengths == 0L)) return(0L)

  n <- max(lengths)
  bad <- lengths != 1L & lengths != n
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
