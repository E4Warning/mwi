test_that("mwi_category() applies the documented boundaries", {
  expect_equal(as.character(mwi_category(0)), "No activity")
  expect_equal(as.character(mwi_category(0.33)), "Low activity")
  expect_equal(as.character(mwi_category(0.34)), "Moderate activity")
  expect_equal(as.character(mwi_category(0.66)), "Moderate activity")
  expect_equal(as.character(mwi_category(0.67)), "High activity")
  expect_equal(as.character(mwi_category(0.999)), "High activity")
  expect_equal(as.character(mwi_category(1)), "Very high activity")
})

test_that("boundaries are closed on the right, so each is in the lower class", {
  expect_equal(as.character(mwi_category(c(0.33, 0.66))),
               c("Low activity", "Moderate activity"))
  expect_equal(as.character(mwi_category(c(0.3300001, 0.6600001))),
               c("Moderate activity", "High activity"))
})

test_that("mwi_category() returns an ordered factor with all five levels", {
  x <- mwi_category(0.5)
  expect_s3_class(x, "ordered")
  expect_equal(levels(x), mwi_activity_levels())
  expect_length(levels(x), 5)
})

test_that("ordered comparison works", {
  expect_true(mwi_category(0.9) > mwi_category(0.2))
  expect_true(mwi_category(1) == max(mwi_category(c(0, 0.5, 1))))
})

test_that("mwi_category() propagates NA and handles empty input", {
  expect_true(is.na(mwi_category(NA_real_)))
  expect_equal(as.character(mwi_category(c(0.5, NA))),
               c("Moderate activity", NA))
  expect_length(mwi_category(numeric(0)), 0)
})

test_that("mwi_category() rejects values outside [0, 1]", {
  expect_error(mwi_category(1.5), "outside that range")
  expect_error(mwi_category(-0.1), "outside that range")
})

test_that("mwi_category() accepts custom labels", {
  labs <- c("none", "low", "mod", "high", "vhigh")
  expect_equal(as.character(mwi_category(c(0, 1), labels = labs)),
               c("none", "vhigh"))
  expect_error(mwi_category(0.5, labels = letters[1:3]), "exactly 5 elements")
})

test_that("every class is reachable from real weather inputs", {
  # No / low / moderate / high from plausible weather, very high at the optimum
  got <- as.character(mwi_category(c(
    mwi(10, 70, 5),
    mwi(16.5, 50, 5),
    mwi(19, 75, 5),
    mwi(22, 85, 5),
    mwi(22, 95, 5)
  )))
  expect_equal(got, mwi_activity_levels())
})
