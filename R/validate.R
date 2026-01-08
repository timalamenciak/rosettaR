# Internal: Load the Python bridge module
.rosetta_bridge <- function() {
  # Ensure Python is initialized
  if (!reticulate::py_available(initialize = TRUE)) {
    stop("Python is not available. Please install Python and the 'linkml' package.")
  }

  # Check if linkml is installed
  if (!reticulate::py_module_available("linkml")) {
    stop("The Python 'linkml' package is required. Please run `pip install linkml` in your Python environment.")
  }

  # Load our internal script
  path <- system.file("python", package = "rosettaR")
  if (path == "") {
    # Fallback for dev mode (if package isn't installed yet)
    path <- file.path("inst", "python")
  }

  reticulate::import_from_path(
    module = "rosetta_bridge",
    path = path,
    convert = TRUE
  )
}

#' Validate a data frame against a LinkML schema
#'
#' @param data A data frame (e.g. from rosetta_format) or list.
#' @param schema Path to the LinkML schema YAML file.
#' @param target_class The class in the schema to validate against.
#'
#' @return A list containing `ok` (boolean) and `issues` (list of errors).
#' @examples
#' \dontrun{
#'   # Create a YAML schema for this example.
#'   schema_yaml <- "id: https://example.org/apple-schema
#'   name: AppleSchema
#'    imports:
#'    - linkml:types
#'    default_range: string
#'  classes:
#'    AppleObservation:
#'     attributes:
#'       object:
#'         required: true
#'       value:
#'         range: float  # Value must be a number!
#'       unit:
#'         range: string"
#'
#' # Save to a temporary file for this example
#' schema_file <- tempfile(fileext = ".yaml")
#' writeLines(schema_yaml, schema_file)# (Use the same setup as above)
#'
#' good_data <- data.frame(object = "Apple A", value = 150.5, unit = "g")
#' res_good <- rosetta_validate(good_data, schema_file, target_class = "AppleObservation")
#' print(paste("Good Data is Valid:", res_good$ok))
#' }
#' @export
rosetta_validate <- function(data, schema, target_class = NULL) {
  if (!file.exists(schema)) {
    rlang::abort(paste0("Schema file does not exist: ", schema))
  }

  # 1. Load Bridge
  bridge <- .rosetta_bridge()

  # 2. Convert Data to JSON
  # We use auto_unbox=TRUE so single values aren't wrapped in arrays [ ]
  instance_json <- jsonlite::toJSON(data, auto_unbox = TRUE, null = "null")

  # 3. Call Python
  res <- bridge$validate_json_instance(
    schema_path   = normalizePath(schema),
    instance_json = instance_json,
    target_class  = target_class
  )

  return(res)
}
