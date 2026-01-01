#' Match Multiple Statements Against a Template Library
#'
#' Iterates through a vector of statements and attempts to match them against
#' a library of templates. Returns a long-format dataframe.
#'
#' @param statements A character vector of plain language statements.
#' @param templates A dataframe created by `init_library()`, containing
#' 'TemplateID' and 'templateText' columns.
#'
#' @return A data.frame in long format with columns: statement_id, statement_text, template_id, variable, value.
#' @export
rosetta_match <- function(statements, templates) {

  # 1. Validation: Ensure templates is a valid library dataframe
  req_cols <- c("TemplateID", "templateText")
  if (!is.data.frame(templates) || !all(req_cols %in% names(templates))) {
    stop("Error: 'templates' must be a dataframe with 'TemplateID' and 'templateText' columns (as created by init_library).")
  }

  results_list <- list()

  # 2. Iterate over every statement
  for (i in seq_along(statements)) {
    stmt <- statements[i]
    matched <- FALSE

    # 3. Iterate through the Template Dataframe rows
    for (j in 1:nrow(templates)) {

      tmpl_name <- templates$TemplateID[j]
      tmpl_text <- templates$templateText[j]

      tryCatch({
        # Attempt match
        extracted <- rosetta_format(stmt, tmpl_text, out_template = "df")

        # Convert to Long Format
        long_df <- data.frame(
          statement_id = i,
          statement_text = stmt,
          template_id = tmpl_name,
          variable = names(extracted),
          value = as.character(unlist(extracted[1, ])),
          stringsAsFactors = FALSE
        )

        results_list[[length(results_list) + 1]] <- long_df
        matched <- TRUE

        break # Stop checking templates for this statement once matched

      }, error = function(e) {
        # No match, continue to next template
      })
    }
  }

  # 4. Return results
  if (length(results_list) == 0) {
    return(data.frame(statement_id=integer(), statement_text=character(),
                      template_id=character(), variable=character(),
                      value=character()))
  }

  final_df <- do.call(rbind, results_list)
  rownames(final_df) <- NULL
  return(final_df)
}
