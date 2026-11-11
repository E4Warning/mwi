# Regression tests against values produced by the analysis pipeline that
# generated the published results.
#
# fixtures/pipeline-reference.rds holds 314 hourly ERA5-Land observations from
# the Moschato-Tavros study period (valid_time in UTC), together with the
# response-function values and the index exactly as the pipeline computed them.
# Rows were stratified across every regime of every response function (both
# sides of each temperature breakpoint, both humidity cut-offs, both sides of
# the wind threshold) and the extremes were added explicitly, so the fixture
# exercises the whole domain rather than the comfortable middle of it.
#
# The fixture is stored as .rds, not CSV, because the comparisons are exact:
# MCMC amplifies last-bit differences in covariates into visibly different
# posterior summaries, so "equal to within a tolerance" is not good enough for
# the replication package to reproduce the published numbers. (Text formats
# cannot guarantee an exact round trip of doubles in R, even at 17 digits.)
#
# These tests are the package's guard against silently drifting away from the
# published analysis. If one fails, the package and the article disagree.

ref <- readRDS(test_path("fixtures", "pipeline-reference.rds"))

test_that("the fixture still covers every regime", {
  expect_gt(nrow(ref), 300)
  expect_gt(sum(ref$ft == 0), 50)   # outside the temperature trapezoid
  expect_gt(sum(ref$fh == 0), 50)   # outside the 40-95% humidity band
  expect_gt(sum(ref$fw == 0), 50)   # above the wind cut-off
  expect_gt(sum(ref$mwi > 0), 50)   # and a decent number of active hours
})

test_that("mwi_temperature() reproduces the pipeline", {
  expect_identical(mwi_temperature(ref$temperature), ref$ft)
})

test_that("mwi_humidity() reproduces the pipeline", {
  expect_identical(mwi_humidity(ref$humidity), ref$fh)
})

test_that("mwi_wind() reproduces the pipeline", {
  expect_identical(mwi_wind(ref$wind_speed_kmph), ref$fw)
})

test_that("mwi() reproduces the pipeline", {
  expect_identical(
    mwi(ref$temperature, ref$humidity, ref$wind_speed_kmph),
    ref$mwi
  )
})

test_that("the index equals the product of its parts on real data", {
  expect_identical(ref$ft * ref$fh * ref$fw, ref$mwi)
})

test_that("mwi_fhft() equals the pipeline index wherever wind is below the cut-off", {
  calm <- ref$fw == 1
  expect_gt(sum(calm), 50)
  expect_identical(
    mwi_fhft(ref$temperature[calm], ref$humidity[calm]),
    ref$mwi[calm]
  )
})

test_that("wind units agree on real observations", {
  expect_equal(
    mwi_wind(ref$wind_speed_kmph / 3.6, units = "m/s"),
    ref$fw
  )
})

test_that("mwi_category() matches the pipeline's categorisation", {
  # The pipeline labels the classes in title case; the package defaults to
  # sentence case, so the labels are supplied explicitly here. The boundaries
  # are what is being tested.
  pipeline_labels <- c("No Activity", "Low Activity", "Moderate Activity",
                       "High Activity", "Very High Activity")
  got <- as.character(mwi_category(ref$mwi, labels = pipeline_labels))

  expected <- ifelse(
    ref$mwi == 0, pipeline_labels[1],
    ifelse(ref$mwi <= 0.33, pipeline_labels[2],
      ifelse(ref$mwi <= 0.66, pipeline_labels[3],
        ifelse(ref$mwi < 1, pipeline_labels[4], pipeline_labels[5])
      )
    )
  )
  expect_equal(got, expected)
})

test_that("no unit warning fires on the study's real observations", {
  expect_no_warning(mwi(ref$temperature, ref$humidity, ref$wind_speed_kmph))
})

test_that("mwi_humidity() is bit-identical to the pipeline's expression", {
  # Tolerance-based comparisons above cannot see last-bit differences, but
  # MCMC amplifies them, so the pipeline's exact floating-point expression is
  # pinned here. See the comment in mwi_humidity().
  h <- c(40, 40.3, 58.15, 67.5, 72.96857827276641, 76.3, 94.99, 95,
         ref$humidity[ref$humidity >= 40 & ref$humidity <= 95])
  expect_identical(mwi_humidity(h), h / 55 - 40 / 55)
  expect_identical(mwi_humidity(c(40, 95)), c(0, 1))
})
