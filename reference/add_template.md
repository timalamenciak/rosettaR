# Add a template string to the library

Add a template string to the library

## Usage

``` r
add_template(library, template, meta_id = NA)
```

## Arguments

- library:

  Input must be a library dataframe created by initLibrary()

- template:

  This should be one string template.

- meta_id:

  It can have a meta-template ID.

## Value

A new library data frame containing the template that was added.

## Examples

``` r
templates <- init_library()
templates <- add_template(templates, apple_template)
```
