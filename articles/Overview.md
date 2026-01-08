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

| object  | quality | value  | unit  |
|:--------|:--------|:-------|:------|
| Apple X | weight  | 241.68 | grams |

That’s a pretty straightforward usage, but we can get more complicated
with it. Here we can transform the statement into a CSV, where the slots
become column headers and the values go in the columns:

``` r
rosetta_format(apple_statement, apple_template, "Object,Quality,Value,Unit\n{{ object }},{{ quality }},{{ value }},{{ unit }}")
#> [1] "Object,Quality,Value,Unit\nApple X,weight,241.68,grams"
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
    iao:has_measurement_value "241.68"^^xsd:double ;
    iao:has_measurement_unit_label uo:0000021 .

############################################################
## UNIT
############################################################

uo:0000021
    rdf:type uo:grams .
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
# Create an empty library
empty_lib <- init_library()
knitr::kable(empty_lib)
```

| TemplateID | templateText | metaTemplateID |
|------------|--------------|----------------|

Now let’s load a real set of templates that we have included as an
example using the
[`init_library()`](https://timalamenciak.github.io/rosettaR/reference/init_library.md)
function. This function verifies that the template file is formatted
properly:

``` r
templates <- init_library(system.file("extdata/apple_templates.csv", package="rosettaR"))
knitr::kable(templates)
```

| TemplateID | templateText                                                          | metaTemplateID |
|-----------:|:----------------------------------------------------------------------|:---------------|
|          1 | {{ object }} has a {{ quality }} of {{ value }} {{ unit }}            | NA             |
|          2 | {{ object }} was grown in {{ location }} and picked {{ date_picked }} | NA             |
|          3 | {{ object }} has the effect of making a human {{ magical_effect }}    | NA             |

Next, let’s load some statements. Note that these are just plain text
strings:

``` r
statements <- read.csv(system.file("extdata/apple_statements.csv", package="rosettaR"))
head(statements)
#>   TemplateID                                              statement
#> 1          1                   Apple X has a weight of 2332.4 grams
#> 2          1                       Apple Y has a weight of 23 stone
#> 3          2           Apple X was grown in Germany and picked 2025
#> 4          2 Apple Y was grown in Canada and picked January 4, 2025
#> 5          3         Apple X has the effect of making a human happy
#> 6          3        Apple Y has the effect of making a human sleepy
```

We can now use the
[`rosetta_match()`](https://timalamenciak.github.io/rosettaR/reference/rosetta_match.md)
function. This “router” function automatically iterates through your
statements, finds the matching template in your library, and extracts
the data.

Unlike the simple rosetta_format which returns a wide dataframe (columns
for variables), `rosetta_match` returns a Long Dataframe
(Entity-Attribute-Value). This ensures that we don’t get a “sparse
matrix” full of NAs when mixing different templates.

``` r
results <- rosetta_match(statements, templates)
knitr::kable(head(results, 10))
```

| statement_id | statement_text                               | template_id | variable | value   |
|-------------:|:---------------------------------------------|------------:|:---------|:--------|
|            1 | Apple X has a weight of 2332.4 grams         |           1 | object   | Apple X |
|            1 | Apple X has a weight of 2332.4 grams         |           1 | quality  | weight  |
|            1 | Apple X has a weight of 2332.4 grams         |           1 | value    | 2332.4  |
|            1 | Apple X has a weight of 2332.4 grams         |           1 | unit     | grams   |
|            2 | Apple Y has a weight of 23 stone             |           1 | object   | Apple Y |
|            2 | Apple Y has a weight of 23 stone             |           1 | quality  | weight  |
|            2 | Apple Y has a weight of 23 stone             |           1 | value    | 23      |
|            2 | Apple Y has a weight of 23 stone             |           1 | unit     | stone   |
|            3 | Apple X was grown in Germany and picked 2025 |           2 | object   | Apple X |
|            3 | Apple X was grown in Germany and picked 2025 |           2 | location | Germany |

This output structure is ideal for building knowledge graphs, as every
row corresponds to a single semantic fact (Subject-Predicate-Object).

## Advanced templating

Real-world data is rarely as clean as “Apple 1 has a weight of 100 g”.
Often, statements include optional details or citations. `rosettaR`
supports advanced template syntax to handle these cases.

### Optional information in templates

You can mark parts of a template as optional by enclosing them in square
brackets `[...]`. If the text inside the brackets is missing from the
statement, the parser will simply skip it (and return empty values for
those slots) rather than throwing an error.

``` r
# Template with optional 'region' block
tmpl <- "{{ city }} is located in {{ country }} [in the region of {{ region }}]"

# Statement WITH region
s1 <- "Kitchener is located in Canada in the region of Waterloo"
knitr::kable(rosetta_format(s1, tmpl))
```

| city      | country | region   |
|:----------|:--------|:---------|
| Kitchener | Canada  | Waterloo |

``` r

# Statement WITHOUT region
s2 <- "Kitchener is located in Canada"
knitr::kable(rosetta_format(s2, tmpl))
```

| city      | country | region |
|:----------|:--------|:-------|
| Kitchener | Canada  |        |

### Attribution and sources

A key requirement for scientific knowledge graphs is attribution. You
can include citation logic directly in your templates. This makes it
explicit which statement is associated with which source.

``` r
# Template explicitly asking for a DOI
cited_tmpl <- "{{ city }} is in {{ country }} according to {{ doi }}"

# Input statement
stmt <- "Kitchener is in Canada according to 10.123/example"

# Result captures both the fact AND the source
knitr::kable(rosetta_format(stmt, cited_tmpl))
```

| city      | country | doi            |
|:----------|:--------|:---------------|
| Kitchener | Canada  | 10.123/example |

### Validation

Extracting data is only half the battle; we also need to ensure it is
valid. rosettaR integrates with LinkML (via Python) to validate your
extracted data against a schema.

This ensures, for example, that an extracted “Age” is actually a number,
or that a “Country” matches a specific list of allowed terms.

#### Defining a schema

LinkML schemas are defined in YAML. Here is a simple example schema for
our Apple data:

``` r
schema_yaml <- "
id: [https://example.org/apple-schema](https://example.org/apple-schema)
name: AppleSchema
imports:
  - linkml:types
default_range: string

classes:
  AppleObservation:
    attributes:
      object:
        required: true
      value:
        range: float  # Value must be a number!
      unit:
        range: string
"
# Save to a temporary file for this example
schema_file <- tempfile(fileext = ".yaml")
writeLines(schema_yaml, schema_file)
```

#### Validating data

We can take the output from `rosetta_format` and check it against this
schema.

``` r
# 1. Good Data
good_data <- data.frame(object = "Apple A", value = 150.5, unit = "g")
res_good <- rosetta_validate(good_data, schema_file, target_class = "AppleObservation")
print(paste("Good Data is Valid:", res_good$ok))

# 2. Bad Data (Value is a string 'Heavy', not a float)
bad_data <- data.frame(object = "Apple B", value = "Heavy", unit = "g")
res_bad <- rosetta_validate(bad_data, schema_file, target_class = "AppleObservation")

print(paste("Bad Data is Valid:", res_bad$ok))
if (!res_bad$ok) {
  print(res_bad$issues)
}
```

This validation step acts as a powerful gatekeeper, ensuring that only
high-quality, structured data enters your final knowledge graph. \#
Under construction - much more to come! **To do:**

- Add slot validation functionality
- Document multiple template/statement pairs and template library
  functionality
- Fix regex in Rosetta_format
- Fix rosetta_match function
