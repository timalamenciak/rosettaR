# Parse a Rosetta Statement

Converts a plain language statement into a structured dataframe using a
template. Supports variables {{ var }} and optional blocks \[ ... \].

## Usage

``` r
rosetta_format(s, in_template, out_template = "df")
```

## Arguments

- s:

  The input statement string.

- in_template:

  The Rosetta template string.

- out_template:

  The output format ('df' for dataframe, 'rdf' for generic Turtle, or a
  Jinja string).

## Value

Either a data frame or the output template with values filled in from
statement and input template.

## Examples

``` r
# example code
rosetta_format("Apple X weighs 235 grams", "{{ fruit }} weighs {{ value }} {{ unit}}")
#>     fruit value  unit
#> 1 Apple X   235 grams
```
