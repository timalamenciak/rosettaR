# Load a set of Rosetta templates into a dataframe.

Load a set of Rosetta templates into a dataframe.

## Usage

``` r
init_library(file = NA)
```

## Arguments

- file:

  A CSV with the headers 'TemplateID' and 'templateText'. Headers are
  case-sensitive and required. Other functions like
  [`df_to_statements()`](https://timalamenciak.github.io/rosettaR/reference/df_to_statements.md)
  and
  [`add_template()`](https://timalamenciak.github.io/rosettaR/reference/add_template.md)
  will expect a data frame in the format created by this function.

## Value

A dataframe containing either the loaded templates or the proper headers
for use with other functions.

## Examples

``` r
#Initialize an empty library
templates <- init_library()

#Load a CSV library
apple_templates <- init_library(system.file("extdata", "apple_templates.csv",
 package="rosettaR"))
```
