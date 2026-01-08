# Batch Convert Statements to RSO RDF

Converts a list of statements into a single, cohesive Turtle (TTL)
string using the Rosetta Statement Ontology (RSO). Handles prefix
management automatically.

## Usage

``` r
rosetta_triplify(statements, templates)
```

## Arguments

- statements:

  A character vector of plain language statements.

- templates:

  A dataframe created by
  [`init_library()`](https://timalamenciak.github.io/rosettaR/reference/init_library.md).

## Value

A single character string containing the full RDF document.

## Examples

``` r
if (FALSE) { # \dontrun{
  # (Use the same setup as above)
  ttl <- rosetta_triplify(statements, templates)
  cat(ttl)
} # }
```
