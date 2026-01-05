# Match Multiple Statements Against a Template Library

Iterates through a vector of statements and attempts to match them
against a library of templates. Returns a long-format dataframe.

## Usage

``` r
rosetta_match(statements, templates)
```

## Arguments

- statements:

  A character vector of plain language statements.

- templates:

  A dataframe created by
  [`init_library()`](https://timalamenciak.github.io/rosettaR/reference/init_library.md),
  containing 'TemplateID' and 'templateText' columns.

## Value

A data.frame in long format with columns: statement_id, statement_text,
template_id, variable, value.
