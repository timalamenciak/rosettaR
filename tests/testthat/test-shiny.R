test_that("App launches successfully", {
  skip_on_cran()

  app_dir <- system.file("shiny/rosetta_ui", package = "rosettaR")

  # Just initializing it proves it doesn't have syntax errors
  app <- shinytest2::AppDriver$new(app_dir)

  # If we reached this line, the app started!
  expect_true(TRUE)
})
