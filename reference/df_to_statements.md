# Change a data frame into a series of statements based on templates.

Change a data frame into a series of statements based on templates.

## Usage

``` r
df_to_statements(df, templates)
```

## Arguments

- df:

  A data frame with headers that match the slots in a template. The
  dataframe must have one column called "TemplateID" that contains the
  ID of the template used to interpret the row.

- templates:

  A Rosetta Statement template library created by the initLibrary
  function.

## Value

A data frame statement library containing the statements and associated
templates.

## Examples

``` r
templates <- init_library()
templates <- add_template(templates, apple_template)
statements <- df_to_statements(data.frame(object = "Apple X",
                              quality = "weight", value="100.2",
                             unit="grams", TemplateID = "1"),templates)
```
