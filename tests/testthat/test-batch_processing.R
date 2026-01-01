test_that("rosetta_match handles init_library dataframe structure", {

  # 1. The Corpus
  statements <- c(
    "Kitchener is located in Canada",
    "Paris is located in France",
    "The apple costs $1.00"
  )

  # 2. The Template Library (Dataframe format per init_library)
  templates <- data.frame(
    TemplateID = c("geo_tmpl", "price_tmpl"),
    templateText = c(
      "{{ city }} is located in {{ country }}",
      "The {{ item }} costs ${{ amount }}"
    ),
    metaTemplateID = c("meta_geo", "meta_econ"),
    stringsAsFactors = FALSE
  )

  # 3. Run the function
  result <- rosetta_match(statements, templates)

  # 4. Expectations
  expect_equal(nrow(result), 6)

  # Check that it pulled the correct IDs from the dataframe
  st1 <- result[result$statement_id == 1, ]
  expect_true("geo_tmpl" %in% st1$template_id)

  st3 <- result[result$statement_id == 3, ]
  expect_true("price_tmpl" %in% st3$template_id)
})
