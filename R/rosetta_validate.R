#' Validate a Rosetta Statement using LinkML.
#'
#' @param statement A statement sentence string or data frame of statements.
#' @param template A template or data frame of templates.
#'
#' @returns True if valid, otherwise a LinkML format report.
#' @export
#'
#' @examples
rosettaValidate <- function (statement, template) {
  linkmlR::linkmlr_install_python_deps(method = "pip", envname = "linkmlr")
}
