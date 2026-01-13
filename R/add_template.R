#' Add a template string to the library
#'
#' @param library Input must be a library dataframe created by initLibrary()
#' @param template This should be one string template.
#'
#' @returns A new library data frame containing the template that was added.
#' @export
#'
#' @examples
#' templates <- init_library()
#' templates <- add_template(templates, apple_template)
add_template <- function(library, template) {
library <- rbind(library, data.frame(TemplateID = nrow(library)+1,
                                     templateText = template))
return(library)
}
