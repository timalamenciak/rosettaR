
# This is a Shiny interface for the rosettaR package. Currently it is
# a pretty cludgy experience. Revising.

# ------------------------- UI ------------------------- #
ui <- bslib::page_navbar(
  title = "Rosetta Statements interface",
  theme = bslib::bs_theme(5, "flatly"),
  navbar_options = bslib::navbar_options(class = "bg-primary", theme = "dark"),
  bslib::nav_panel(title = "Engine",
            shiny::p("Rosetta Statement processing")),
  bslib::nav_panel(title = "Template library",
            shiny::p("Rosetta Statement templates"))
)


# ------------------------- Server ------------------------- #
server <- function(input, output, session) {

}

shiny::shinyApp(ui = ui, server = server)
