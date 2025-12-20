#' Rosetta Statements Shiny interface
#'
#' @returns Nothing.
#' @export
#'
#' @examples
#' \dontrun{
#' rosetta_shiny()
#' }
rosetta_shiny <- function() {

  # ------------------------- UI ------------------------- #
  ui <- bslib::page_navbar(
    title = "Rosetta Statements interface",
    theme = bslib::bs_theme(5, "flatly"),
    navbar_options = bslib::navbar_options(class = "bg-primary", theme = "dark"),

    bslib::nav_panel(
      title = "Engine",
      bslib::card(
        full_screen = FALSE,
        bslib::card_header("1. Upload Input Data"),
        shiny::p("Upload either a Rosetta statement CSV (TemplateID + statementText)
       or a raw data-frame CSV (must include TemplateID)."),
        shiny::radioButtons(
          "engine_input_type",
          "Select input type:",
          choices = c(
            "Statements CSV (TemplateID + statementText)" = "statements",
            "Data-frame CSV with TemplateID (to convert to statements)" = "dataframe"
          )
        ),
        shiny::fileInput("engine_input_file", "Upload CSV", accept = ".csv"),
        shiny::uiOutput("engine_input_preview")
      ),
      bslib::card(
        full_screen = FALSE,
        bslib::card_header("2. Convert Data Using Templates"),
        shiny::tabsetPanel(
          shiny::tabPanel(
            "Create Statements",
            shiny::p("Convert a data frame into Rosetta Statements using the TemplateID column."),
            shiny::actionButton(
              "convert_to_statements_btn",
              "Generate Statements",
              class = "btn btn-primary mt-2"
            ),
            DT::DTOutput("engine_statements_out"),
            shiny::downloadButton("download_statements_btn", "Download Statements")
          ),
          shiny::tabPanel(
            "Convert Statements (Jinja)",
            shiny::p("Enter a Jinja template to convert statements into sentences, CSV rows, TTL triples, etc."),
            shiny::textAreaInput(
              "engine_output_template",
              "Jinja Output Template:",
              placeholder = "{{ id }}, {{ city }}, {{ country }}",
              height = "200px"
            ),
            shiny::actionButton(
              "convert_statements_template_btn",
              "Convert Statements",
              class = "btn btn-success mt-2"
            ),
            shiny::verbatimTextOutput("engine_converted_output"),
            shiny::downloadButton("download_converted_output_btn", "Download Output")
          )
        )
      )
    ),

    bslib::nav_panel(
      title = "Template library",
      DT::DTOutput("template_table"),
      bslib::card(
        bslib::card_header("Template creator"),
        shiny::textAreaInput("template_text", "Template (Jinja syntax)", height = "200px"),
        shiny::uiOutput("template_variable_display"),
        shiny::actionButton("add_template_btn", "Add / Update Template", class = "btn-primary"),
        shiny::actionButton("delete_template_btn", "Delete Template", class = "btn-danger"),
        shiny::fileInput("import_templates", "Import Template Library (.csv or .rds)"),
        shiny::downloadButton("export_templates", "Export Current Library")
      )
    )
  )

  # ------------------------- Server ------------------------- #
  server <- function(input, output, session) {

    rv <- shiny::reactiveValues(
      templates = rosettaR::init_library(),
      statements = data.frame(
        TemplateID = as.character(),
        statementText = as.character()
      )
    )

    output$template_table <- DT::renderDT({
      rv$templates
    }, selection = "single")

    shiny::observeEvent(input$template_table_rows_selected, {
      row <- rv$templates[input$template_table_rows_selected, ]
      shiny::updateTextInput(session, "template_id", value = row$id)
      shiny::updateTextAreaInput(session, "template_text", value = row$templateText)
    })

    #output$template_variable_display <- renderUI({
    #  req(input$template_text)
    #  vars <- rosettaR::extract_variables(input$template_text)
    #  tagList(
    #    strong("Detected variables:"),
    #    tags$ul(lapply(vars, tags$li))
    #  )
    #})

    shiny::observeEvent(input$add_template_btn, {
      rv$templates <- rosettaR::add_template(rv$templates, input$template_text)
    })

    shiny::observeEvent(input$delete_template_btn, {
      rv$templates <- rv$templates[rv$templates$id != input$template_id, ]
    })

    shiny::observeEvent(input$import_templates, {
      path <- input$import_templates$datapath
      if (grepl("\\.csv$", path)) rv$templates <- utils::read.csv(path, stringsAsFactors = FALSE)
    })

    output$export_templates <- shiny::downloadHandler(
      filename = "template_library.csv",
      content = function(file) utils::write.csv(rv$templates, file, row.names = FALSE)
    )

    shiny::observeEvent(input$engine_input_file, {
      shiny::req(input$engine_input_file)
      df <- utils::read.csv(input$engine_input_file$datapath, stringsAsFactors = FALSE)

      if (input$engine_input_type == "statements") {
        shiny::validate(
          shiny::need("TemplateID" %in% names(df), "File missing TemplateID column."),
          shiny::need("statementText" %in% names(df), "File missing statementText column.")
        )
        rv$statements <- df

      } else if (input$engine_input_type == "dataframe") {
        shiny::validate(shiny::need("TemplateID" %in% names(df), "Data frame must include a TemplateID column."))
        rv$data_input <- df
      }
    })

    output$engine_input_preview <- shiny::renderUI({
      shiny::req(input$engine_input_file)
      bslib::card(
        bslib::card_header("Preview"),
        DT::DTOutput("engine_input_preview_table")
      )
    })

    output$engine_input_preview_table <- DT::renderDT({
      if (input$engine_input_type == "statements") rv$statements else rv$data_input
    })

    shiny::observeEvent(input$convert_to_statements_btn, {
      shiny::req(rv$data_input)
      rv$statements <- rosettaR::df_to_statements(df = rv$data_input, library = rv$templates)
    })

    output$engine_statements_out <- DT::renderDT({
      shiny::req(rv$statements)
      rv$statements
    })

    output$download_statements_btn <- shiny::downloadHandler(
      filename = "rosetta_statements.csv",
      content = function(file) utils::write.csv(rv$statements, file, row.names = FALSE)
    )

    shiny::observeEvent(input$convert_statements_template_btn, {
      shiny::req(rv$statements, input$engine_output_template)
      rv$converted_output <- rosettaR::rosetta_format(
        rv$statements,
        template = input$engine_output_template
      )
    })

    output$engine_converted_output <- shiny::renderText({
      shiny::req(rv$converted_output)
      rv$converted_output
    })

    output$download_converted_output_btn <- shiny::downloadHandler(
      filename = "converted_output.txt",
      content = function(file) writeLines(rv$converted_output, file)
    )
  }

  shiny::shinyApp(ui = ui, server = server)
}
