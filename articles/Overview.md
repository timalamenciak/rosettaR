# Overview

``` r
library(rosettaR)
```

This vignette explains the overall usage of the `rosettaR` package,
including its core functions and workflows. At its heart, `rosettaR` is
a templating system with extra window dressing and rules. This document
will walk through the basic usage, starting with a single template
example and expanding to multi-template data frames.

You can see the original pre-print for the conceptual background to
Rosetta Statements: [Rosetta Statements: Simplifying FAIR Knowledge
Graph Construction with a User-Centered
Approach](https://arxiv.org/abs/2407.20007).

Here are some key terms:

- **Slot** - Think of a slot as a blank to be filled in a Mad Lib. These
  are denoted in the templates using [Jinja-style
  notation](https://jinja.palletsprojects.com/en/stable/), which means
  that slots will look like this: `{{ object }}`

- **Template** - A template is a string with slots for particular data
  types. For example:
  `{{ object }} has a {{ quality }} of {{ value }} {{ unit }}`

- **Statement** - A statement is a plain language sentence that contains
  entries for slots. For example: `Apple X has a weight of 241.68 grams`

Templates are made up of slots and semantic information that links them
together. The slots are filled by statements, which can be parsed by
`rosettaR` into any different data structure.

## Single template-statement pair

There are two variables saved in the package for you to work with. This
template-statement pair describes the weight of an apple. Let’s declare
them here so we can see what is inside:

``` r
print(apple_template)
#> [1] "{{ object }} has a {{ quality }} of {{ value }} {{ unit }}"
print(apple_statement)
#> [1] "Apple X has a weight of 241.68 grams"
```

The idea behind `rosettaR` is that one may want to model the knowledge
contained in this sentence in multiple ways. The template-statement pair
constitutes a core piece of information (sometimes called a “semantic
anchor”) that can be transformed into multiple representations.

Here we can turn it into a data frame:

``` r
knitr::kable(rosetta_format(apple_statement, apple_template))
```

| object  | quality | value | unit        |
|:--------|:--------|:------|:------------|
| Apple X | weight  | 2     | 41.68 grams |

That’s a pretty straightforward usage, but we can get more complicated
with it. Here we can transform the statement into a CSV, where the slots
become column headers and the values go in the columns:

``` r
rosetta_format(apple_statement, apple_template, "Object,Quality,Value,Unit\n{{ object }},{{ quality }},{{ value }},{{ unit }}")
#> [1] "Object,Quality,Value,Unit\nApple X,weight,2,41.68 grams"
```

We’re still in pretty simple territory here, so let’s get a little more
complex. The original idea behind Rosetta Statements was to make it
easier to create knowledge graphs in RDF. So here is an example of an
RDF graph that describes the weight of an apple:

``` r
apple_rdf <- '@prefix ex:    <http://example.org/instance/> .
@prefix ncit:  <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#> .
@prefix pato:  <http://purl.obolibrary.org/obo/PATO_> .
@prefix iao:   <http://purl.obolibrary.org/obo/IAO_> .
@prefix obi:   <http://purl.obolibrary.org/obo/OBI_> .
@prefix ro:    <http://purl.obolibrary.org/obo/RO_> .
@prefix uo:    <http://purl.obolibrary.org/obo/UO_> .
@prefix rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs:  <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd:   <http://www.w3.org/2001/XMLSchema#> .

############################################################
## OBJECT: the particular apple
############################################################

ex:apple
    rdf:type ncit:apple ;
    rdfs:label "{{ object }}" ;
    ro:has_quality ex:apple{{ quality }} .

############################################################
## QUALITY: weight of the apple
############################################################

ex:apple{{ quality }}
    rdf:type pato:{{ quality }} ;                 # PATO:weight
    iao:is_about ex:apple ;
    iao:is_quality_measured_as ex:apple{{ quality }}Datum .

############################################################
## MEASUREMENT DATUM
############################################################

ex:apple{{ quality }}Datum
    rdf:type iao:0000109 ;                  # IAO:scalar measurement datum
    obi:has_value_specification ex:apple{{ quality }}ValueSpec .

############################################################
## VALUE SPECIFICATION
############################################################

ex:apple{{ quality }}ValueSpec
    rdf:type obi:0001938 ;                  # OBI:scalar value specification
    iao:has_measurement_value "{{ value }}"^^xsd:double ;
    iao:has_measurement_unit_label uo:0000021 .

############################################################
## UNIT
############################################################

uo:0000021
    rdf:type uo:{{ unit }} .'
```

Describing what exactly this TTL does is beyond the scope of this
vignette, but if you are reading this it is likely you have some idea
about RDF/OWL/etc. So let’s feed that string into our workflow and see
what happens:

``` r
cat(rosetta_format(apple_statement, apple_template, apple_rdf))
@prefix ex:    <http://example.org/instance/> .
@prefix ncit:  <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#> .
@prefix pato:  <http://purl.obolibrary.org/obo/PATO_> .
@prefix iao:   <http://purl.obolibrary.org/obo/IAO_> .
@prefix obi:   <http://purl.obolibrary.org/obo/OBI_> .
@prefix ro:    <http://purl.obolibrary.org/obo/RO_> .
@prefix uo:    <http://purl.obolibrary.org/obo/UO_> .
@prefix rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs:  <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd:   <http://www.w3.org/2001/XMLSchema#> .

############################################################
## OBJECT: the particular apple
############################################################

ex:apple
    rdf:type ncit:apple ;
    rdfs:label "Apple X" ;
    ro:has_quality ex:appleweight .

############################################################
## QUALITY: weight of the apple
############################################################

ex:appleweight
    rdf:type pato:weight ;                 # PATO:weight
    iao:is_about ex:apple ;
    iao:is_quality_measured_as ex:appleweightDatum .

############################################################
## MEASUREMENT DATUM
############################################################

ex:appleweightDatum
    rdf:type iao:0000109 ;                  # IAO:scalar measurement datum
    obi:has_value_specification ex:appleweightValueSpec .

############################################################
## VALUE SPECIFICATION
############################################################

ex:appleweightValueSpec
    rdf:type obi:0001938 ;                  # OBI:scalar value specification
    iao:has_measurement_value "2"^^xsd:double ;
    iao:has_measurement_unit_label uo:0000021 .

############################################################
## UNIT
############################################################

uo:0000021
    rdf:type uo:41.68 grams .
```

## Processing multiple statements

Doing a single statement is fairly trivial. The real power of Rosetta
Statements comes when you have a lot of statements using multiple
templates. In order to make this work, there needs to be a library of
templates.

This “library” is a simple data frame, but it has to have specific
headers. We have built a command that creates one (or loads one from a
properly formatted CSV)

``` r
templates <- init_library()
knitr::kable(templates)
```

| TemplateID | templateText | metaTemplateID |
|------------|--------------|----------------|

This creates a blank data frame. You can add templates using the
[`add_template()`](https://timalamenciak.github.io/rosettaR/reference/add_template.md)
function, which is a pretty simple statement that adds a new template
given a string and optional meta template ID (more on meta templates
later).

Let’s load a set of templates that we have included as an example. You
can use [`read.csv()`](https://rdrr.io/r/utils/read.table.html) for
this, but the
[`init_library()`](https://timalamenciak.github.io/rosettaR/reference/init_library.md)
function also verifies that the template file is formatted properly:

``` r
templates <- init_library(system.file("extdata/apple_templates.csv", package="rosettaR"))
knitr::kable(templates)
```

| TemplateID | templateText                                                          | metaTemplateID |
|-----------:|:----------------------------------------------------------------------|:---------------|
|          1 | {{ object }} has a {{ quality }} of {{ value }} {{ unit }}            | NA             |
|          2 | {{ object }} was grown in {{ location }} and picked {{ date_picked }} | NA             |
|          3 | {{ object }} has the effect of making a human {{ magical_effect }}    | NA             |

So now we have a data frame with 3 templates about apples. Let’s load
some statements:

``` r
statements <- read.csv(system.file("extdata/apple_statements.csv", package="rosettaR"))
knitr::kable(statements)
```

| TemplateID | statement                                              |
|-----------:|:-------------------------------------------------------|
|          1 | Apple X has a weight of 2332.4 grams                   |
|          1 | Apple Y has a weight of 23 stone                       |
|          2 | Apple X was grown in Germany and picked 2025           |
|          2 | Apple Y was grown in Canada and picked January 4, 2025 |
|          3 | Apple X has the effect of making a human happy         |
|          3 | Apple Y has the effect of making a human sleepy        |

Now we can convert each statement into a data frame:

``` r
results <- data.frame()
merged <- dplyr::inner_join(statements, templates, by = "TemplateID")
for (i in 1:nrow(merged)) {
  row = merged[i, ]
}
```

This loop mashes all the results into one data frame. It looks something
like this:

## Under construction - much more to come!

**To do:**

- Add slot validation functionality
- Document multiple template/statement pairs and template library
  functionality
