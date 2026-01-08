library(shiny)
library(rosettaR) # Ensure the package functions are available

ui <- fluidPage(
  titlePanel("RosettaR Workbench"),

  sidebarLayout(
    sidebarPanel(
      textAreaInput("statement", "Statement",
                    value = "Kitchener is located in Canada",
                    rows = 3),
      textAreaInput("in_template", "Input Template",
                    value = "{{ city }} is located in {{ country }}",
                    rows = 3),
      textAreaInput("out_template", "Output Template (Jinja2 or 'df')",
                    value = "df",
                    rows = 2),
      actionButton("run", "Convert", class = "btn-primary"),
      hr(),
      h4("Validation (LinkML)"),
      fileInput("schema_file", "Upload Schema (.yaml)", accept = ".yaml"),
      uiOutput("class_selector"), # Dynamic dropdown for classes
      actionButton("validate", "Validate Data", class = "btn-success")
    ),

    mainPanel(
      tabsetPanel(
        tabPanel("Data Output",
                 h4("Converted Data"),
                 tableOutput("result_table"),
                 verbatimTextOutput("error_log")
        ),
        tabPanel("Validation Report",
                 h4("LinkML Validation Status"),
                 verbatimTextOutput("validation_status"),
                 verbatimTextOutput("validation_issues")
        )
      )
    )
  )
)

server <- function(input, output, session) {

  # Reactive value to store the converted dataframe
  converted_data <- reactiveVal(NULL)

  # 1. Run Conversion
  observeEvent(input$run, {
    output$error_log <- renderText("") # Clear errors

    tryCatch({
      res <- rosetta_format(
        s = input$statement,
        in_template = input$in_template,
        out_template = input$out_template
      )
      converted_data(res)

      output$result_table <- renderTable({
        if (is.data.frame(res)) res else as.data.frame(res)
      })
    }, error = function(e) {
      output$error_log <- renderText(paste("Error:", e$message))
      converted_data(NULL)
    })
  })

  # 2. Dynamic Class Selector (reads schema to find classes)
  # Note: This is a placeholder. For a full implementation, you'd parse the YAML
  # to find class names. For now,
  # we just let them type it or default to 'Person'.
  output$class_selector <- renderUI({
    req(input$schema_file)
    textInput("target_class", "Target Class", value = "Person")
  })

  # 3. Run Validation
  observeEvent(input$validate, {
    req(converted_data(), input$schema_file)

    res <- rosetta_validate(
      data = converted_data(),
      schema = input$schema_file$datapath,
      target_class = input$target_class
    )

    output$validation_status <- renderText({
      if (res$ok) "✅ VALID" else "❌ INVALID"
    })

    output$validation_issues <- renderText({
      if (length(res$issues) > 0) {
        paste(res$issues, collapse = "\n")
      } else {
        "No issues found."
      }
    })
  })
}

shinyApp(ui, server)
