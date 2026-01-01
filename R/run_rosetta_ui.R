#' Launch the RosettaR UI
#'
#' Opens a Shiny application to interactively test Rosetta templates and validation.
#'
#' @export
run_rosetta_ui <- function() {
  # Locate the app directory inside the installed package
  app_dir <- system.file("shiny", "rosetta_ui", package = "rosettaR")

  if (app_dir == "") {
    stop("Could not find the Shiny app. Try re-installing `rosettaR`.")
  }

  shiny::runApp(app_dir, display.mode = "normal")
}
