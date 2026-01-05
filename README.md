
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rosettaR

<!-- badges: start -->

<!-- badges: end -->

The goal of rosettaR is to provide a series of tools to work with
Rosetta Statements, which are plain language statements that can be
converted to semantic data when paired with a template.

## Installation

You can install the development version of rosettaR from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("timalamenciak/rosettaR")
```

## Example

This is a basic example of how `rosettaR` can convert data:

``` r
library(rosettaR)
statement <- "Kitchener is located in Canada"
in_template <- "{{ city }} is located in {{ country }}"
out_template <- "CITY,COUNTRY,,{{ city }},{{ country }}"
df <- rosetta_format(statement, in_template, out_template)
```

# Development notes

This is a very early version of this package. It is based on the idea of
Rosetta Statements described in [Rosetta Statements: Simplifying FAIR
Knowledge Graph Construction with a User-Centered
Approach](https://arxiv.org/abs/2407.20007) by Lars Vogt et al.

## Development tasks

- [ ] Build slot restrictions into template validation workflow.
- [x] Implement slot restrictions and validation using LinkML (major).
- [x] Debug and rework Shiny interface (major).
- [x] Implement support for optional slots.
- [x] Add documentation on working with multiple template-statement
  pairs.
- [ ] Enhance Apple example to use proper RDF, add other data formats.
- [ ] Design hexagon logo for rosettaR.
- [ ] Submit rosettaR to [CRAN](https://cran.r-project.org/).
- [ ] Submit rosettaR for [rOpenSci peer
  review](https://ropensci.org/software-review/).
