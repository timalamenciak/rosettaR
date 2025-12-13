# Load a set of Rosetta templates into a dataframe.

Load a set of Rosetta templates into a dataframe.

## Usage

``` r
init_library(file = NA)
```

## Arguments

- file:

  A CSV with the headers 'TemplateID', 'templateText' and
  'metaTemplateID'. Headers are case-sensitive and required. Other
  functions like df_to_statements() and add_template() will expect a
  data frame in the format created by this function.

## Value

A dataframe containing either the loaded templates or the proper headers
for use with other functions.
