test_that("mwi_temperature() hits the documented breakpoints", {
  expect_equal(mwi_temperature(15), 0)
  expect_equal(mwi_temperature(20), 1)
  expect_equal(mwi_temperature(25), 1)
  expect_equal(mwi_temperature(30), 0)
  # Midpoints of the two ramps
  expect_equal(mwi_temperature(17.5), 0.5)
  expect_equal(mwi_temperature(27.5), 0.5)
})

test_that("mwi_temperature() is zero outside 15-30 and bounded within", {
  expect_equal(mwi_temperature(c(-10, 0, 15, 30.1, 45)), rep(0, 5))
  x <- mwi_temperature(seq(-20, 50, by = 0.1))
  expect_true(all(x >= 0 & x <= 1))
})

test_that("mwi_temperature() ramps are continuous at the plateau edges", {
  expect_equal(mwi_temperature(20 - 1e-8), 1, tolerance = 1e-6)
  expect_equal(mwi_temperature(25 + 1e-8), 1, tolerance = 1e-6)
})

test_that("mwi_humidity() hits the documented breakpoints", {
  expect_equal(mwi_humidity(40), 0)
  expect_equal(mwi_humidity(95), 1)
  expect_equal(mwi_humidity(67.5), 0.5)
  expect_equal(mwi_humidity(c(0, 39.9)), c(0, 0))
})

test_that("mwi_humidity() drops to zero as a step above 95", {
  # Deliberate discontinuity: 95 is the optimum, anything wetter is unsuitable
  expect_equal(mwi_humidity(95), 1)
  expect_equal(mwi_humidity(95.001), 0)
  expect_equal(mwi_humidity(100), 0)
})

test_that("mwi_wind() is a cut-off at 6 m/s", {
  expect_equal(mwi_wind(21.6), 1)
  expect_equal(mwi_wind(21.7), 0)
  expect_equal(mwi_wind(0), 1)
  expect_equal(mwi_wind(6, units = "m/s"), 1)
  expect_equal(mwi_wind(6.1, units = "m/s"), 0)
})

test_that("mwi_wind() unit conversion is consistent", {
  ms <- c(0, 2, 5.9, 6, 6.1, 10)
  expect_equal(mwi_wind(ms, units = "m/s"), mwi_wind(ms * 3.6, units = "km/h"))
})

test_that("mwi_wind_threshold() reports the cut-off in both units", {
  expect_equal(mwi_wind_threshold(), 21.6)
  expect_equal(mwi_wind_threshold("m/s"), 6)
})

test_that("responses are vectorised and propagate NA", {
  expect_equal(mwi_temperature(c(22, NA, 10)), c(1, NA, 0))
  expect_equal(mwi_humidity(c(70, NA)), c((70 - 40) / 55, NA))
  expect_equal(mwi_wind(c(5, NA)), c(1, NA))
  expect_length(mwi_temperature(numeric(0)), 0)
})

test_that("responses reject non-numeric input", {
  expect_error(mwi_temperature("22"), "must be numeric")
  expect_error(mwi_humidity(TRUE), "must be numeric")
})
