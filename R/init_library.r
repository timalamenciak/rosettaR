#' Load a set of Rosetta templates into a dataframe.
#'
#' @param file A CSV with the headers 'TemplateID' and 'templateText'.
#' Headers are case-sensitive and required. Other functions
#' like `df_to_statements()` and `add_template()` will expect a data frame in the
#' format created by this function.
#'
#' @returns A dataframe containing either the loaded templates or the proper
#' headers for use with other functions.
#' @export
#'
#' @examples
#' #Initialize an empty library
#' templates <- init_library()
#'
#' #Load a CSV library
#' apple_templates <- init_library(system.file("extdata", "apple_templates.csv",
#'  package="rosettaR"))
init_library <- function (file = NA) {
  if (missing(file)) {
    return(data.frame(TemplateID = as.character(),
                      templateText = as.character()))
    } else {
      templates <- utils::read.csv(file)
    #Verify the format:
    #Required columns:
    # TemplateID
    # templateText
    # metaTemplateID (value not required)

    req_n <- c("TemplateID", "templateText")
    #Verify that each required column is present
    for (i in seq_len(length(req_n))) {
      if (!(req_n[i] %in% colnames(templates))){
        stop(paste0("Error: Required column ", req_n[i], " not found."))
      }
    }
    return(templates)
  }
}
