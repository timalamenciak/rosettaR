test_that("rosetta_format handles optional semantic blocks [ ... ]", {

  # 1. Basic Optional Block
  tmpl <- "{{ city }} is in [the province of {{ province }} in] {{ country }}"

  # Case A: Block Present
  stmt_full <- "Kitchener is in the province of Ontario in Canada"
  res_full <- rosetta_format(stmt_full, tmpl)
  expect_equal(res_full$city, "Kitchener")
  expect_equal(res_full$province, "Ontario")
  expect_equal(res_full$country, "Canada")

  # Case B: Block Missing
  stmt_short <- "Kitchener is in Canada"
  res_short <- rosetta_format(stmt_short, tmpl)
  expect_equal(res_short$city, "Kitchener")
  expect_equal(res_short$province, "")
  expect_equal(res_short$country, "Canada")

  # Case C: Wrong Text in Block (Should skip block)
  # "state" does not match "province", so the optional block is skipped.
  # "the state of Ontario in Canada" is consumed by {{ country }}
  stmt_wrong <- "Kitchener is in the state of Ontario in Canada"
  res_wrong <- rosetta_format(stmt_wrong, tmpl)
  expect_equal(res_wrong$province, "")
  expect_true(grepl("state of", res_wrong$country))
})

test_that("rosetta_format handles nested optional blocks", {

  # 2. Nested Optional Blocks
  # Logic: An address might have a Unit, inside a Building, inside a Street.
  # Template: "Address: [Unit {{ unit }} in [Building {{ building }} at]] {{ street }}"

  tmpl <- "Address: [Unit {{ unit }} in [Building {{ building }} at]] {{ street }}"

  # Case A: Full Depth (Unit + Building + Street)
  s1 <- "Address: Unit 4B in Building West at Main St"
  r1 <- rosetta_format(s1, tmpl)
  expect_equal(r1$unit, "4B")
  expect_equal(r1$building, "West")
  expect_equal(r1$street, "Main St")

  # Case B: Partial Depth (Building + Street, NO Unit)
  # This implies the outer block matches, but the inner text aligns differently?
  # Actually, if "Unit" word is missing, the ENTIRE outer block fails.
  # So everything goes to {{ street }}.
  s2 <- "Address: Building West at Main St"
  r2 <- rosetta_format(s2, tmpl)
  expect_equal(r2$unit, "")
  expect_equal(r2$building, "")
  # Result: "Building West at Main St" matches {{ street }}
  expect_equal(r2$street, "Building West at Main St")

  # Case C: Clean Skip (Just Street)
  s3 <- "Address: Main St"
  r3 <- rosetta_format(s3, tmpl)
  expect_equal(r3$unit, "")
  expect_equal(r3$building, "")
  expect_equal(r3$street, "Main St")
})
