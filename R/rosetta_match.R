#' Match Multiple Statements Against a Template Library
#'
#' Iterates through a vector of statements and attempts to match them against
#' a library of templates. Returns a long-format dataframe.
#'
#' @param statements A character vector of plain language statements, OR a dataframe containing a column of statements.
#' @param templates A dataframe created by `init_library()`, containing
#' 'TemplateID' and 'templateText' columns.
#'
#' @return A data.frame in long format with columns: statement_id, statement_text, template_id, variable, value.
#' @examples
#' \dontrun{
#'    # Vector Input
#'    statements <- c("Kitchener is in Canada", "Paris is in France")
#'
#'    # Dataframe Input (e.g. from read.csv)
#'    # df <- read.csv("my_statements.csv")
#'
#'    templates <- init_library(system.file("extdata/apple_templates.csv", package="rosettaR"))
#'    results <- rosetta_match(statements, templates)
#' }
#' @export
rosetta_match <- function(statements, templates) {

  # 1. Validation: Templates
  req_cols <- c("TemplateID", "templateText")
  if (!is.data.frame(templates) || !all(req_cols %in% names(templates))) {
    stop("Error: 'templates' must be a dataframe with 'TemplateID' and 'templateText' columns.")
  }

  # 2. Input Normalization: Handle Dataframe vs Vector
  # If the user passed a dataframe (like from read.csv), we need to extract the text vector.
  statements_vec <- NULL

  if (is.data.frame(statements)) {
    # Heuristic: Look for a column named 'text' or 'statement' (case insensitive)
    col_names <- tolower(names(statements))
    target_col <- match("text", col_names)
    if (is.na(target_col)) target_col <- match("statement", col_names)
    if (is.na(target_col)) target_col <- match("statements", col_names)

    if (!is.na(target_col)) {
      statements_vec <- as.character(statements[[target_col]])
    } else if (ncol(statements) == 1) {
      # If there's only one column, assume that's the one
      statements_vec <- as.character(statements[[1]])
    } else {
      # Fallback: Try to find the first character column
      char_cols <- sapply(statements, is.character)
      if (any(char_cols)) {
        statements_vec <- statements[[which(char_cols)[1]]]
        warning(paste("Dataframe passed to rosetta_match. Using column:", names(statements)[which(char_cols)[1]]))
      } else {
        stop("Error: 'statements' is a dataframe but I cannot determine which column contains the text. Please pass a vector or rename your column to 'text'.")
      }
    }
  } else {
    # It's already a vector (hopefully)
    statements_vec <- as.character(statements)
  }

  # Safety check for that "String looks like code" bug
  if (length(statements_vec) == 1 && grepl("^c\\s*\\(", statements_vec)) {
    warning("Input looks like an R code string (e.g. 'c(\"...\")') rather than a vector. Did you read a file incorrectly?")
  }

  results_list <- list()

  # 3. Iterate over statements
  for (i in seq_along(statements_vec)) {

    stmt <- trimws(statements_vec[i])
    if (nchar(stmt) == 0) next

    matched <- FALSE

    # 4. Iterate through Templates
    for (j in seq_len(nrow(templates))) {

      tmpl_name <- templates$TemplateID[j]
      tmpl_text <- templates$templateText[j]

      tryCatch({
        # Attempt match
        extracted <- rosetta_format(stmt, tmpl_text, out_template = "df")

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
        break

      }, error = function(e) {
        # Ignore mismatches, warn on bugs
        if (!grepl("Input string does not match", e$message)) {
          warning(paste("Statement", i, "template", tmpl_name, "error:", e$message))
        }
      })
    }
  }

  # 5. Return results
  if (length(results_list) == 0) {
    return(data.frame(
      statement_id=integer(),
      statement_text=character(),
      template_id=character(),
      variable=character(),
      value=character(),
      stringsAsFactors = FALSE
    ))
  }

  final_df <- do.call(rbind, results_list)
  rownames(final_df) <- NULL
  return(final_df)
}
