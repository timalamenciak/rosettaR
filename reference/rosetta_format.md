# Change the format of a statement

Change the format of a statement

## Usage

``` r
rosetta_format(s, in_template, out_template = "df")
```

## Arguments

- s:

  A statement in the form of a string.

- in_template:

  A Rosetta Template to interpret the string.

- out_template:

  A Jinja template for the desired output. (Optional; if not provided, a
  dataframe is returned)

## Value

A string rendered from the Jinja output template and the Rosetta input
template.

## Examples

``` r
statement <- "Kitchener is located in Canada"
in_template <- "{{ city }} is located in {{ country }}"
out_template <- "CITY,COUNTRY,,{{ city }},{{ country }}"
df <- rosetta_format(statement, in_template, out_template)
```
