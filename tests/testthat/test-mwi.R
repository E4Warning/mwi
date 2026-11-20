test_that("mwi() is the product of the three responses", {
  temp <- c(16, 22, 28)
  rh <- c(50, 70, 90)
  wind <- c(1, 10, 20)
  expect_equal(
    mwi(temp, rh, wind),
    mwi_temperature(temp) * mwi_humidity(rh) * mwi_wind(wind)
  )
})

test_that("mwi() attains 1 only at the joint optimum", {
  expect_equal(mwi(22, 95, 0), 1)
  expect_lt(mwi(22, 94, 0), 1)
  expect_lt(mwi(19, 95, 0), 1)
})

test_that("any single factor out of range zeroes the index", {
  expect_equal(mwi(10, 70, 5), 0) # too cold
  expect_equal(mwi(35, 70, 5), 0) # too hot
  expect_equal(mwi(22, 30, 5), 0) # too dry
  expect_equal(mwi(22, 99, 5), 0) # too wet
  expect_equal(mwi(22, 70, 30), 0) # too windy
})

test_that("mwi() stays within [0, 1] across a wide input grid", {
  g <- expand.grid(
    t = seq(-5, 45, by = 2.5),
    h = seq(0, 100, by = 5),
    w = c(0, 10, 21.6, 30)
  )
  x <- mwi(g$t, g$h, g$w)
  expect_true(all(x >= 0 & x <= 1))
  expect_false(anyNA(x))
})

test_that("mwi() recycles length-one arguments", {
  expect_length(mwi(c(18, 22, 28), 70, 5), 3)
  expect_equal(mwi(22, c(50, 70), 5), mwi(c(22, 22), c(50, 70), c(5, 5)))
})

test_that("mwi() rejects incompatible lengths, not partial recycling", {
  expect_error(mwi(c(20, 22, 24, 26), c(60, 70), 5), "same length or length 1")
})

test_that("mwi() propagates NA", {
  expect_equal(mwi(c(22, NA), 70, 5), c(mwi(22, 70, 5), NA))
  expect_true(is.na(mwi(22, NA, 5)))
  expect_true(is.na(mwi(22, 70, NA)))
})

test_that("mwi() honours wind units", {
  # 8 m/s is 28.8 km/h, above the cut-off; 8 km/h is below it
  expect_equal(mwi(22, 70, 8, units = "m/s"), 0)
  expect_gt(mwi(22, 70, 8, units = "km/h"), 0)
})

test_that("mwi_fhft() equals mwi() whenever wind is below the cut-off", {
  temp <- c(16, 22, 28)
  rh <- c(50, 70, 90)
  expect_equal(mwi_fhft(temp, rh), mwi(temp, rh, wind_speed = 0))
})

test_that("mwi_fhft() ignores wind entirely", {
  expect_gt(mwi_fhft(22, 70), 0)
  expect_equal(mwi_fhft(22, 70), mwi_humidity(70) * mwi_temperature(22))
})

test_that("zero-length input yields zero-length output through recycling", {
  expect_length(mwi(numeric(0), 70, 5), 0)
  expect_length(mwi_fhft(numeric(0), numeric(0)), 0)
})

test_that("the index stays lined up with a series that has gaps", {
  # A week of hourly weather with holes in different places in each variable.
  # The result must have one value per hour, be missing exactly in the hours
  # where an input is missing, and elsewhere equal the values computed from the
  # complete hours alone. Otherwise index values would drift away from the
  # times they belong to.
  hours <- 0:167
  temp <- 22 + 6 * sin((hours - 9) / 24 * 2 * pi)
  rh <- 65 - 20 * sin((hours - 9) / 24 * 2 * pi)
  wind <- rep(c(5, 12, 25), length.out = length(hours))
  temp[c(1, 40:43, 100)] <- NA
  rh[c(2, 41, 120:125, 168)] <- NA
  wind[c(3, 77)] <- NA

  x <- mwi(temp, rh, wind)
  gap <- is.na(temp) | is.na(rh) | is.na(wind)

  expect_length(x, length(hours))
  expect_identical(is.na(x), gap)
  expect_identical(x[!gap], mwi(temp[!gap], rh[!gap], wind[!gap]))
  expect_identical(mwi_fhft(temp, rh)[!is.na(temp) & !is.na(rh)],
                   mwi_fhft(temp[!is.na(temp) & !is.na(rh)], rh[!is.na(temp) & !is.na(rh)]))
})
