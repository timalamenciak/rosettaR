#' Load a set of Rosetta templates into a dataframe.
#'
#' @param file A CSV with the headers 'id', 'templateText' and 'metaTemplateID'. Headers are case-sensitive and required.
#'
#' @returns A dataframe containing templates for use with other functions.
#' @export
#'
#' @examples
#' t_file <- data.frame("id" = 1,
#'                     "templateText" = "{{ city }} is in {{ country }},
#'                     "metaTemplateID" = 2)
#' tf <- tempfile()
#' writeLines(t_file, tf)
#' templates <- loadTemplates(tf)
loadTemplates <- function(file) {
  templates <- utils::read.csv(file)
  #Verify the format:
  #Required columns:
  # id
  # templateText
  # metaTemplateID (value not required)

  req_n = c("id", "templateText", "metaTemplateID")
  #Verify that each required column is present
  for (i in 1:length(req_n)) {
    if (!(req_n[i] %in% colnames(templates))){
      stop(paste0("Error: Required column ", req_n[i], " not found."))
    }
  }
  return(templates)
}
