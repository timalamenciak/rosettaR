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
