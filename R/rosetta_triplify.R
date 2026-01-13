#' Batch Convert Statements to RSO RDF
#'
#' Converts a list of statements into a single, cohesive Turtle (TTL) string
#' using the Rosetta Statement Ontology (RSO).
#' Handles prefix management automatically.
#'
#' @param statements A character vector of plain language statements.
#' @param templates A dataframe created by `init_library()`.
#'
#' @return A single character string containing the full RDF document.
#' @examples
#' \dontrun{
#'   # (Use the same setup as above)
#'   ttl <- rosetta_triplify(statements, templates)
#'   cat(ttl)
#' }
#' @export
rosetta_triplify <- function(statements, templates) {

  # 1. Validation
  if (!is.character(statements)) {
    stop("Error: 'statements' must be a character vector.")
  }
  req_cols <- c("TemplateID", "templateText")
  if (!is.data.frame(templates) || !all(req_cols %in% names(templates))) {
    stop("Error: 'templates' must be a dataframe with
         TemplateID and templateText.")
  }

  # 2. Define Standard Headers (RSO)
  # We will put these at the very top of the file once.
  rdf_header <- paste0(
    "@prefix rso: <http://purl.obolibrary.org/obo/RSO_> .\n",
    "@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .\n",
    "@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .\n"
  )

  rdf_bodies <- character()

  # 3. Iterate Statements
  for (i in seq_along(statements)) {
    stmt <- statements[i]

    # Check match against templates
    for (j in seq_len(nrow(templates))) {
      tmpl_text <- templates$templateText[j]

      # Attempt Parse
      tryCatch({
        # We ask for "rdf" output explicitly
        chunk <- rosetta_format(stmt, tmpl_text, out_template = "rdf")

        # CLEANUP: Remove lines starting with @prefix
        # We process the chunk line-by-line to be safe
        lines <- unlist(strsplit(chunk, "\n"))
        body_lines <- lines[!grepl("^\\s*@prefix", lines)]

        # Collapse back into a block
        clean_chunk <- paste(body_lines, collapse = "\n")

        rdf_bodies <- c(rdf_bodies, clean_chunk)

        break # Stop after first match
      }, error = function(e) {
        # Continue
      })
    }
  }

  if (length(rdf_bodies) == 0) {
    warning("No statements matched any templates.")
    return("")
  }

  # 4. Assemble Final Document
  full_doc <- paste(rdf_header, paste(rdf_bodies, collapse = "\n"), sep = "\n")
  return(full_doc)
}
