test_that("rosetta_validate correctly validates data using Python bridge", {
  # 1. Skip if Python/LinkML is missing (so it doesn't fail on machines without setup)
  skip_if_not(reticulate::py_module_available("linkml"), "LinkML python library not installed")

  # 2. Create a temporary schema for testing
  schema_content <- "
id: https://example.org/test
name: TestSchema
imports:
  - linkml:types
default_range: string
classes:
  Person:
    attributes:
      name:
        required: true
      age:
        range: integer
"
  schema_file <- tempfile(fileext = ".yaml")
  writeLines(schema_content, schema_file)

  # 3. Test Valid Data
  good_df <- data.frame(name = "Tim", age = 30)
  res_good <- rosetta_validate(good_df, schema_file, "Person")
  expect_true(res_good$ok)
  expect_length(res_good$issues, 0)

  # 4. Test Invalid Data (Wrong type for age, missing name)
  bad_df <- data.frame(name = NA, age = "Old")
  res_bad <- rosetta_validate(bad_df, schema_file, "Person")
  expect_false(res_bad$ok)
  expect_gt(length(res_bad$issues), 0)
})
