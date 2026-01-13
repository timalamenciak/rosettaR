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


