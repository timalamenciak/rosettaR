#' Parse a Rosetta Statement
#'
#' Converts a plain language statement into a structured dataframe using a template.
#' Supports variables \{\{ var \}\} and optional blocks [ ... ].
#'
#' @param s The input statement string.
#' @param in_template The Rosetta template string.
#' @param out_template The output format ('df' for dataframe, 'rdf' for generic Turtle, or a Jinja string).
#'
#' @export
rosetta_format <- function(s, in_template, out_template = "df") {

  # --- Step 1: Tokenize the Template ---
  token_pattern <- "(\\{\\{.*?\\}\\}|\\[|\\])"
  positions <- gregexpr(token_pattern, in_template, perl = TRUE)[[1]]

  if (positions[1] == -1) {
    tokens <- list(in_template)
    types <- "literal"
  } else {
    match_lengths <- attr(positions, "match.length")
    tokens <- list()
    types <- character()
    last_pos <- 1

    for (i in seq_along(positions)) {
      start <- positions[i]
      len <- match_lengths[i]

      if (start > last_pos) {
        literal <- substr(in_template, last_pos, start - 1)
        tokens[[length(tokens) + 1]] <- literal
        types <- c(types, "literal")
      }

      token_str <- substr(in_template, start, start + len - 1)
      tokens[[length(tokens) + 1]] <- token_str

      if (token_str == "[") {
        types <- c(types, "bracket_open")
      } else if (token_str == "]") {
        types <- c(types, "bracket_close")
      } else {
        types <- c(types, "variable")
      }

      last_pos <- start + len
    }

    if (last_pos <= nchar(in_template)) {
      tokens[[length(tokens) + 1]] <- substr(in_template, last_pos, nchar(in_template))
      types <- c(types, "literal")
    }
  }

  # --- Step 2: Build Regex ---
  final_regex <- "^"
  var_names <- character()

  for (i in seq_along(tokens)) {
    type <- types[i]
    val <- tokens[[i]]

    if (type == "literal") {
      escaped <- gsub("([.|()\\^{}+$*?]|\\[|\\]|\\\\)", "\\\\\\1", val)
      escaped <- gsub("\\s+", "\\\\s*", escaped)
      final_regex <- paste0(final_regex, escaped)

    } else if (type == "bracket_open") {
      final_regex <- paste0(final_regex, "(?:")

    } else if (type == "bracket_close") {
      final_regex <- paste0(final_regex, ")?")

    } else if (type == "variable") {
      raw_name <- gsub("\\{\\{\\s*|\\s*\\}\\}", "", val)
      is_optional_var <- grepl("^\\?", raw_name)
      clean_name <- gsub("^\\?\\s*", "", raw_name)
      var_names <- c(var_names, clean_name)

      is_last_token <- (i == length(tokens))
      if (is_last_token) {
        final_regex <- paste0(final_regex, if(is_optional_var) "(.*)" else "(.+)")
      } else {
        final_regex <- paste0(final_regex, if(is_optional_var) "(.*?)" else "(.+?)")
      }
    }
  }

  final_regex <- paste0(final_regex, "$")

  # --- Step 3: Execute ---
  matches <- regmatches(s, regexec(final_regex, s, perl = TRUE))[[1]]

  if (length(matches) < 2) {
    stop("Error: Input string does not match template pattern")
  }

  captured_values <- matches[-1]
  values_named <- as.list(captured_values)
  names(values_named) <- var_names

  # --- Step 4: Output Rendering ---

  # NEW: Generate a Deterministic ID for this statement
  # We use MD5 hash of the statement text to ensure consistency
  # (Requires 'digest' package, or we can use a basic R workaround)
  if (requireNamespace("digest", quietly = TRUE)) {
    stmt_hash <- digest::digest(s, algo = "md5")
  } else {
    # Fallback if digest isn't installed: simple random string (not ideal for determinism)
    stmt_hash <- as.character(as.hexmode(as.integer(Sys.time())))
  }
  stmt_id <- paste0("urn:uuid:", stmt_hash)

  if (out_template == "df") {
    rendered <- as.data.frame(values_named, stringsAsFactors = FALSE)

  } else if (out_template == "rdf") {

    # BUILT-IN RSO TEMPLATE
    # Now uses <{{ statement_id }}> instead of []
    rso_template_str <- '
@prefix rso: <http://purl.obolibrary.org/obo/RSO_> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .

<{{ statement_id }}> a rso:Statement ;
    rso:has_content "{{ source_text }}" ;
    {% for key, value in all_vars %}
    rso:has_variable [
        a rso:Variable ;
        rso:variable_name "{{ key }}" ;
        rso:variable_value "{{ value }}"
    ] ;
    {% endfor %}
.
'
    rendered <- jinjar::render(
      rso_template_str,
      all_vars = values_named,
      source_text = s,
      statement_id = stmt_id, # <--- Passed here
      !!!values_named
    )

  } else {
    # Custom Jinja Template
    rendered <- jinjar::render(
      out_template,
      all_vars = values_named,
      source_text = s,
      statement_id = stmt_id,
      !!!values_named
    )
  }

  return(rendered)
}
