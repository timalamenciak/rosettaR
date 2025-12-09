#' Add a template string to the library
#'
#' @param library Input must be a library dataframe created by initLibrary()
#' @param template This should be one string template.
#' @param meta_id It can have a meta-template ID.
#'
#' @returns A new library data frame containing the template that was added.
#' @export
#'
#' @examples
#' templates <- initLibrary()
#' templates <- addTemplate(templates, apple_template)
addTemplate <- function(library, template, meta_id = NA) {
library <- rbind(library, data.frame(id = nrow(library)+1,
                                     templateText = template,
                                     metaTemplateID = meta_id))
return(library)
}
