#' Change the format of a statement
#'
#' @param s A statement in the form of a string.
#' @param in_template A Rosetta Template to interpret the string.
#' @param out_template A Jinja template for the desired output. (Optional; if
#' not provided, a dataframe is returned)
#'
#' @returns A string rendered from the Jinja output template and the Rosetta input template.
#' @export
#'
#' @examples
#' statement <- "Kitchener is located in Canada"
#' in_template <- "{{ city }} is located in {{ country }}"
#' out_template <- "CITY,COUNTRY,,{{ city }},{{ country }}"
#' df <- rosetta_format(statement, in_template, out_template)
rosetta_format <- function(s, in_template, out_template = "df") {
  # Extract variable names from template (everything between {{ }})
  var_pattern <- "\\{\\{\\s*([^}]+?)\\s*\\}\\}"
  var_names <- regmatches(in_template, gregexpr(var_pattern, in_template, perl = TRUE))[[1]]
  var_names <- gsub("\\{\\{\\s*|\\s*\\}\\}", "", var_names)

  regex_pattern <- in_template
  # Replace {{ var }} with capture groups
  regex_pattern <- gsub("\\{\\{\\s*[^}]+?\\s*\\}\\}", "(.*)", regex_pattern)

  # Extract values from the input string
  matches <- regmatches(s, regexec(regex_pattern, s, perl = TRUE))[[1]]

  # Check if match was successful
  if (length(matches) < 2) {
    stop("Input string does not match template pattern")
  }

  # First element is the full match, rest are capture groups
  values <- matches[-1]
  values_named <- as.list(values)
  names(values_named) <- var_names
  if (out_template == "df") {
    rendered <- as.data.frame(values_named)
  } else {
    rendered <- jinjar::render(out_template, !!!values_named)
  }
  return(rendered)
}
