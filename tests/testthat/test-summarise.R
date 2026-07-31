# A synthetic day whose temperature peaks in mid-afternoon and whose humidity
# peaks before dawn, which is the usual phase relationship and the reason the
# order of operations matters.
synthetic_day <- function(n = 24) {
  hours <- seq_len(n) - 1
  list(
    temp = 18 + 8 * sin((hours - 6) / 24 * 2 * pi),
    rh   = 75 - 15 * sin((hours - 6) / 24 * 2 * pi),
    wind = rep(5, n)
  )
}

test_that("mwi_summarise() computes the index before aggregating", {
  d <- synthetic_day()
  got <- mwi_summarise(d$temp, d$rh, d$wind, by = rep("2019-07-15", 24))
  expect_equal(got$mwi, max(mwi(d$temp, d$rh, d$wind)))
})

test_that("aggregating first gives a different answer from aggregating last", {
  d <- synthetic_day()
  correct <- mwi_summarise(d$temp, d$rh, d$wind, by = rep("d", 24))$mwi
  wrong <- mwi(max(d$temp), max(d$rh), max(d$wind))
  expect_false(isTRUE(all.equal(correct, wrong)))
})

test_that("statistic argument selects the summary", {
  d <- synthetic_day()
  by <- rep("d", 24)
  v <- mwi(d$temp, d$rh, d$wind)
  expect_equal(mwi_summarise(d$temp, d$rh, d$wind, by, "max")$mwi, max(v))
  expect_equal(mwi_summarise(d$temp, d$rh, d$wind, by, "mean")$mwi, mean(v))
  expect_equal(mwi_summarise(d$temp, d$rh, d$wind, by, "min")$mwi, min(v))
})

test_that("groups are respected and reported in sorted order", {
  d <- synthetic_day(48)
  by <- rep(c("2019-07-15", "2019-07-16"), each = 24)
  got <- mwi_summarise(d$temp, d$rh, d$wind, by = by)
  expect_equal(nrow(got), 2)
  expect_equal(got$by, c("2019-07-15", "2019-07-16"))
  expect_equal(got$n, c(24L, 24L))
})

test_that("Date grouping round-trips as a Date", {
  d <- synthetic_day(48)
  by <- rep(as.Date(c("2019-07-15", "2019-07-16")), each = 24)
  got <- mwi_summarise(d$temp, d$rh, d$wind, by = by)
  expect_s3_class(got$by, "Date")
  expect_equal(got$by, as.Date(c("2019-07-15", "2019-07-16")))
})

test_that("by = NULL collapses to one row rather than dropping everything", {
  d <- synthetic_day()
  got <- mwi_summarise(d$temp, d$rh, d$wind, by = NULL)
  expect_equal(nrow(got), 1)
  expect_true(is.na(got$by))
  expect_equal(got$n, 24L)
  expect_equal(got$mwi, max(mwi(d$temp, d$rh, d$wind)))
})

test_that("na.rm controls whether a group with gaps returns NA", {
  d <- synthetic_day()
  d$temp[5] <- NA
  by <- rep("d", 24)
  expect_true(is.na(mwi_summarise(d$temp, d$rh, d$wind, by)$mwi))
  got <- mwi_summarise(d$temp, d$rh, d$wind, by, na.rm = TRUE)
  expect_false(is.na(got$mwi))
  expect_equal(got$n, 23L)
})

test_that("mwi_summarise() rejects a mismatched grouping vector", {
  d <- synthetic_day()
  expect_error(
    mwi_summarise(d$temp, d$rh, d$wind, by = rep("d", 3)),
    "same length as the weather inputs"
  )
})

test_that("mwi_summarise() honours wind units", {
  d <- synthetic_day()
  by <- rep("d", 24)
  # 5 m/s is 18 km/h (below cut-off), so both give a positive index here
  ms <- mwi_summarise(d$temp, d$rh, d$wind, by, units = "m/s")$mwi
  kmh <- mwi_summarise(d$temp, d$rh, d$wind * 3.6, by, units = "km/h")$mwi
  expect_equal(ms, kmh)
})
