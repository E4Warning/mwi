test_that("dewpoint equal to air temperature gives saturation", {
  expect_equal(relative_humidity_from_dewpoint(20, 20), 100)
  expect_equal(relative_humidity_from_dewpoint(-5, -5), 100)
})

test_that("relative humidity falls as the dewpoint depression grows", {
  rh <- relative_humidity_from_dewpoint(dewpoint = c(20, 15, 10, 5), 20)
  expect_true(all(diff(rh) < 0))
  expect_true(all(rh > 0 & rh <= 100))
})

test_that("relative humidity is in a plausible range for known conditions", {
  # 22 C air, 15 C dewpoint is roughly 65% RH
  expect_equal(relative_humidity_from_dewpoint(15, 22), 65, tolerance = 0.02)
})

test_that("humidity conversion is vectorised and propagates NA", {
  expect_length(relative_humidity_from_dewpoint(c(10, 12, 14), 20), 3)
  expect_true(is.na(relative_humidity_from_dewpoint(NA_real_, 20)))
})

test_that("wind_speed_from_components() returns the vector magnitude", {
  expect_equal(wind_speed_from_components(3, 4), 5)
  expect_equal(wind_speed_from_components(0, 0), 0)
  expect_equal(wind_speed_from_components(-3, -4), 5)
})

test_that("wind magnitude is rotation invariant", {
  u <- 2.5
  v <- 1.3
  theta <- pi / 7
  expect_equal(
    wind_speed_from_components(u, v),
    wind_speed_from_components(
      u * cos(theta) - v * sin(theta),
      u * sin(theta) + v * cos(theta)
    )
  )
})

test_that("celsius_from_kelvin() converts correctly", {
  expect_equal(celsius_from_kelvin(273.15), 0)
  expect_equal(celsius_from_kelvin(295.15), 22)
  expect_equal(celsius_from_kelvin(c(273.15, NA)), c(0, NA))
})

test_that("conversions compose into an index, as with ERA5-Land inputs", {
  # ERA5-Land supplies Kelvin temperatures and m/s wind components
  t2m <- 295.15
  d2m <- 288.15
  u10 <- 1.2
  v10 <- -0.8

  temperature <- celsius_from_kelvin(t2m)
  dewpoint <- celsius_from_kelvin(d2m)
  humidity <- relative_humidity_from_dewpoint(dewpoint, temperature)
  wind <- wind_speed_from_components(u10, v10)

  x <- mwi(temperature, humidity, wind, units = "m/s")
  expect_true(x > 0 && x <= 1)
})

test_that("conversions reject non-numeric input", {
  expect_error(celsius_from_kelvin("273"), "must be numeric")
  expect_error(wind_speed_from_components("1", 2), "must be numeric")
})
