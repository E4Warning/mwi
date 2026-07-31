# Regression tests against values produced by the analysis pipeline that
# generated the published results.
#
# fixtures/pipeline-reference.csv holds 314 hourly ERA5-Land observations from
# the Moschato-Tavros study period, together with the response-function values
# and the index as the pipeline computed them. Rows were stratified across every
# regime of every response function (both sides of each temperature breakpoint,
# both humidity cut-offs, both sides of the wind threshold) and the extremes were
# added explicitly, so the fixture exercises the whole domain rather than the
# comfortable middle of it.
#
# These tests are the package's guard against silently drifting away from the
# published analysis. If one fails, the package and the article disagree.

ref <- read.csv(
  test_path("fixtures", "pipeline-reference.csv"),
  stringsAsFactors = FALSE
)

test_that("the fixture still covers every regime", {
  expect_gt(nrow(ref), 300)
  expect_gt(sum(ref$ft == 0), 50)   # outside the temperature trapezoid
  expect_gt(sum(ref$fh == 0), 50)   # outside the 40-95% humidity band
  expect_gt(sum(ref$fw == 0), 50)   # above the wind cut-off
  expect_gt(sum(ref$mwi > 0), 50)   # and a decent number of active hours
})

test_that("mwi_temperature() reproduces the pipeline", {
  expect_equal(mwi_temperature(ref$temperature), ref$ft)
})

test_that("mwi_humidity() reproduces the pipeline", {
  expect_equal(mwi_humidity(ref$humidity), ref$fh)
})

test_that("mwi_wind() reproduces the pipeline", {
  expect_equal(mwi_wind(ref$wind_speed_kmh), ref$fw)
})

test_that("mwi() reproduces the pipeline", {
  expect_equal(
    mwi(ref$temperature, ref$humidity, ref$wind_speed_kmh),
    ref$mwi
  )
})

test_that("the index equals the product of its parts on real data", {
  expect_equal(ref$ft * ref$fh * ref$fw, ref$mwi)
})

test_that("mwi_fhft() equals the pipeline index wherever wind is below the cut-off", {
  calm <- ref$fw == 1
  expect_gt(sum(calm), 50)
  expect_equal(
    mwi_fhft(ref$temperature[calm], ref$humidity[calm]),
    ref$mwi[calm]
  )
})

test_that("wind units agree on real observations", {
  expect_equal(
    mwi_wind(ref$wind_speed_kmh / 3.6, units = "m/s"),
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
