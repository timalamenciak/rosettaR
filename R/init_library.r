#' Load a set of Rosetta templates into a dataframe.
#'
#' @param file A CSV with the headers 'id', 'templateText' and
#' 'metaTemplateID'. Headers are case-sensitive and required. Other functions
#' like df_to_statements() and add_template() will expect a data frame in the
#' format created by this function.
#'
#' @returns A dataframe containing either the loaded templates or the proper
#' headers for use with other functions.
#' @export
#'
#' @examples
#' t_file <- data.frame("id" = 1,
#'                     "templateText" = "{{ city }} is in {{ country }},
#'                     "metaTemplateID" = 2)
#' tf <- tempfile()
#' writeLines(t_file, tf)
#' templates <- init_library(tf)
init_library <- function (file = NA) {
  if (missing(file)){
    return(data.frame(id = as.character(),
                      templateText = as.character(),
                      metaTemplateID = as.character()))
  } else {
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
}
