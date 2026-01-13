test_that("rosetta_format parses a basic city/country statement correctly
          into a data frame", {
  # 1. Setup the inputs
  statement <- "Kitchener is located in Canada"
  in_template <- "{{ city }} is located in {{ country }}"

  # 2. Run the function
  result <- rosetta_format(statement, in_template)

  # 3. Check the structure (Expectations)
  # We expect a data frame (or tibble) result
  expect_s3_class(result, "data.frame")

  # 4. Check the values

  expect_equal(nrow(result), 1) # Should be 1 row
  expect_equal(result[,1], "Kitchener") # Checking the city column
  expect_equal(result[,2], "Canada")    # Checking the country column
})

test_that("rosetta_format fails gracefully
          when statement does not match template", {
  # 1. Setup inputs that clearly don't match
  statement <- "The apple is red"
  in_template <- "{{ city }} is located in {{ country }}"

  # 2. Run the function
  # We are checking if it produces an error.
  # If the function currently returns NA or NULL instead of an error,
  # we might need to adjust this test.
  expect_error(rosetta_format(statement, in_template))
})

test_that("rosetta_format handles special regex characters literals", {
  # 1. Setup: A statement with $ and . (both have special Regex meanings)
  statement <- "The price is $10.50."
  in_template <- "The price is ${{ amount }}."

  # 2. Run
  result <- rosetta_format(statement, in_template)

  # 3. Expectation
  # It should extract "10.50" literally, treating $ and . as just text
  expect_equal(result[,1], "10.50")
})

test_that("rosetta_format handles units with and without spaces", {
  # 1. Setup: two template-statement pairs.
  template1 <- "The cow weighs {{ weight }}kg"
  template2 <- "The cow weighs {{ weight }} kg"
  statement1 <- "The cow weighs 500kg"
  statement2 <- "The cow weighs 500 kg"

  result1 <- rosetta_format(statement1, template1)
  result2 <- rosetta_format(statement2, template2)
  expect_equal(result1[,1], "500")
  expect_equal(result2[,1], "500")
})
