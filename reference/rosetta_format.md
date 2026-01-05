# Parse a Rosetta Statement

Converts a plain language statement into a structured dataframe using a
template. Supports variables {{ var }} and optional blocks ... .

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

  The output format ('df' for dataframe, or a Jinja2 string).
