# Validate a data frame against a LinkML schema

Validate a data frame against a LinkML schema

## Usage

``` r
rosetta_validate(data, schema, target_class = NULL)
```

## Arguments

- data:

  A data frame (e.g. from rosetta_format) or list.

- schema:

  Path to the LinkML schema YAML file.

- target_class:

  The class in the schema to validate against.

## Value

A list containing `ok` (boolean) and `issues` (list of errors).

## Examples

``` r
if (FALSE) { # \dontrun{
  # Create a YAML schema for this example.
  schema_yaml <- "id: https://example.org/apple-schema
  name: AppleSchema
   imports:
   - linkml:types
   default_range: string
 classes:
   AppleObservation:
    attributes:
      object:
        required: true
      value:
        range: float  # Value must be a number!
      unit:
        range: string"

# Save to a temporary file for this example
schema_file <- tempfile(fileext = ".yaml")
writeLines(schema_yaml, schema_file)# (Use the same setup as above)

good_data <- data.frame(object = "Apple A", value = 150.5, unit = "g")
res_good <- rosetta_validate(good_data, schema_file, target_class = "AppleObservation")
print(paste("Good Data is Valid:", res_good$ok))
} # }
```
