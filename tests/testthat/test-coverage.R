test_that("df_to_statements works", {
  df <- data.frame(city="Kitchener", country="Canada", TemplateID = "1")
  templates <- init_library()
  templates <- add_template(templates, "{{city}} is in {{country}}")
  stmts <- df_to_statements(df, templates)
  expect_equal(stmts[1,2], "Kitchener is in Canada")
})

test_that("adding a template works", {
  templates <- init_library()
  templates <- add_template(templates, apple_template)
  expect_equal(templates[1,2],
               "{{ object }} has a {{ quality }} of {{ value }} {{ unit }}")
})

test_that("loading a template file works", {
  templates <- init_library(system.file("extdata", "apple_templates.csv",
                                    package="rosettaR"))
  expect_equal(templates[1,2],
               "{{ object }} has a {{ quality }} of {{ value }} {{ unit }}")
})

test_that("init_library() errors if CSV missing required columns", {
  tmp <- tempfile(fileext = ".csv")
  # Missing TemplateID + templateText on purpose
  write.csv(data.frame(bad = 1), tmp, row.names = FALSE)

  expect_error(
    init_library(tmp),
    regexp = "Required column",
    ignore.case = TRUE
  )
})

test_that("df_to_statements() errors on malformed templates library", {
  df <- data.frame(city="Kitchener", country="Canada", TemplateID="1")
  bad_templates <- data.frame(x = 1)

  expect_error(
    df_to_statements(df, bad_templates),
    regexp = "Template library format is incorrect",
    ignore.case = TRUE
  )
})

test_that("df_to_statements() handles multiple rows", {
  templates <- init_library()
  templates <- add_template(templates, "{{city}} is in {{country}}")

  df <- data.frame(
    city = c("Kitchener", "Paris"),
    country = c("Canada", "France"),
    TemplateID = c("1","1"),
    stringsAsFactors = FALSE
  )

  out <- df_to_statements(df, templates)
  expect_equal(nrow(out), 2)
  expect_match(out$statement[1], "Kitchener")
  expect_match(out$statement[2], "Paris")
})

test_that("rosetta_match() errors if templates missing required columns", {
  expect_error(
    rosetta_match(c("A"), data.frame(x=1)),
    regexp = "templates.*TemplateID.*templateText",
    ignore.case = TRUE
  )
})

test_that("rosetta_match() accepts a 1-column dataframe as statements", {
  statements_df <- data.frame(anything = c("Kitchener is located in Canada"))
  templates <- data.frame(
    TemplateID = "geo",
    templateText = "{{ city }} is located in {{ country }}",
    stringsAsFactors = FALSE
  )

  out <- rosetta_match(statements_df, templates)
  expect_true(nrow(out) > 0)
  expect_true(any(out$value %in% c("Kitchener","Canada")))
})


test_that("rosetta_match() skips empty statements and returns empty df when no matches", {
  templates <- data.frame(
    TemplateID = "geo",
    templateText = "{{ city }} is located in {{ country }}",
    stringsAsFactors = FALSE
  )

  out <- rosetta_match(c("   ", ""), templates)
  expect_s3_class(out, "data.frame")
  expect_equal(nrow(out), 0)  # hits the empty-results return block
})

test_that("rosetta_format() can emit rdf Turtle when out_template='rdf'", {
  stmt <- "Kitchener is located in Canada"
  tmpl <- "{{ city }} is located in {{ country }}"

  ttl <- rosetta_format(stmt, tmpl, out_template = "rdf")

  expect_type(ttl, "character")
  expect_match(ttl, "@prefix")
  expect_match(ttl, "Kitchener")
  expect_match(ttl, "Canada")
})

test_that("rosetta_format() can render a custom output template string", {
  stmt <- "Kitchener is located in Canada"
  tmpl <- "{{ city }} is located in {{ country }}"
  out_tmpl <- "CITY={{ city }},COUNTRY={{ country }}"

  out <- rosetta_format(stmt, tmpl, out_template = out_tmpl)

  expect_type(out, "character")
  expect_equal(out, "CITY=Kitchener,COUNTRY=Canada")
})

test_that("rosetta_format() errors cleanly when statement doesn't match template", {
  expect_error(
    rosetta_format("This will not match", "{{ city }} is located in {{ country }}"),
    regexp = "does not match template",
    ignore.case = TRUE
  )
})

test_that("rosetta_triplify() errors if statements is not character", {
  templates <- data.frame(TemplateID="x", templateText="{{ a }}", stringsAsFactors = FALSE)
  expect_error(rosetta_triplify(123, templates), "must be a character")
})
test_that("rosetta_triplify() errors if templates invalid", {
  expect_error(
    rosetta_triplify(c("A"), data.frame(x=1)),
    regexp = "templates.*dataframe",
    ignore.case = TRUE
  )
})

test_that("rosetta_triplify() warns and returns empty string when nothing matches", {
  templates <- data.frame(
    TemplateID="geo",
    templateText="{{ city }} is located in {{ country }}",
    stringsAsFactors = FALSE
  )

  expect_warning(
    out <- rosetta_triplify(c("Totally unrelated sentence"), templates),
    regexp = "No statements matched",
    ignore.case = TRUE
  )
  expect_equal(out, "")
})

test_that("rosetta_validate() aborts if schema file does not exist", {
  expect_error(
    rosetta_validate(data.frame(x=1), schema="def-not-real.yaml"),
    regexp = "Schema file does not exist",
    ignore.case = TRUE
  )
})
