test_that("rosetta_validate enforces LinkML Enums (Ontology terms)", {
  skip_if_not(reticulate::py_module_available("linkml"),
              "LinkML python library not installed")

  # 1. Define a Schema with an Enum (Controlled Vocabulary)
  # We define a 'CountryEnum' with 3 allowed values.
  # The 'country' slot is restricted to this Enum.
  schema_content <- "
id: https://example.org/geo-schema
name: GeoSchema
imports:
  - linkml:types
default_range: string

enums:
  CountryEnum:
    permissible_values:
      Canada:
        description: A country in North America
      USA:
        description: United States of America
      Mexico:
        description: United Mexican States

classes:
  Location:
    attributes:
      city:
        required: true
      country:
        range: CountryEnum    # <--- This is the validation hook
        required: true
"
  schema_file <- tempfile(fileext = ".yaml")
  writeLines(schema_content, schema_file)

  # 2. Test Valid Data (Canada is in the Enum)
  good_df <- data.frame(city = "Kitchener", country = "Canada")
  res_good <- rosetta_validate(good_df, schema_file, "Location")

  expect_true(res_good$ok)

  # 3. Test Invalid Data ('France' is NOT in the Enum)
  bad_df <- data.frame(city = "Paris", country = "France")
  res_bad <- rosetta_validate(bad_df, schema_file, "Location")

  # This should FAIL because France is not in CountryEnum
  expect_false(res_bad$ok)

  # The error message should mention the constraint violation
  # LinkML error messages can be verbose, so we just check it found issues
  expect_gt(length(res_bad$issues), 0)
})
