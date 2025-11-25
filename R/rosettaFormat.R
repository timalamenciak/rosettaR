#testing template:
test <- "{{ pet }} is not sold in {{ city }}"
train <- "Dog is not sold in kitchener"

rosettaFormat <- function(s, t, f = "df") {
  # Extract variable names from template (everything between {{ }})
  var_pattern <- "\\{\\{\\s*([^}]+?)\\s*\\}\\}"
  var_names <- regmatches(t, gregexpr(var_pattern, t, perl = TRUE))[[1]]
  var_names <- gsub("\\{\\{\\s*|\\s*\\}\\}", "", var_names)

  regex_pattern <- t
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

  # Return based on format
  if (f == "df") {
    # Create a data frame with variable names as columns
    result <- as.data.frame(t(values), stringsAsFactors = FALSE)
    colnames(result) <- var_names
    return(result)
  } else if (f == "list") {
    # Return as named list
    result <- as.list(values)
    names(result) <- var_names
    return(result)
  } else if (f == "vector") {
    # Return as named vector
    result <- setNames(values, var_names)
    return(result)
  } else {
    stop("Invalid format. Use 'df', 'list', or 'vector'")
  }
}
