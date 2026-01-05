test_that("rosetta_triplify generates valid batch RDF", {

  # 1. Setup
  templates <- data.frame(
    TemplateID = c("geo"),
    templateText = c("{{ city }} is in {{ country }}"),
    stringsAsFactors = FALSE
  )

  stmts <- c(
    "Kitchener is in Canada",
    "Paris is in France"
  )

  # 2. Run Batcher
  ttl_output <- rosetta_triplify(stmts, templates)

  # 3. Checks

  # A. Prefixes should appear exactly once (at the top)
  # count pattern matches for "@prefix"
  prefix_count <- length(gregexpr("@prefix", ttl_output)[[1]])
  expect_equal(prefix_count, 3) # rso, xsd, rdfs

  # B. Bodies should be present
  expect_true(grepl("Kitchener", ttl_output))
  expect_true(grepl("Canada", ttl_output))
  expect_true(grepl("Paris", ttl_output))
  expect_true(grepl("France", ttl_output))

  # C. URIs should be distinct (Deterministic UUIDs)
  # We look for the pattern <urn:uuid:...>
  uuids <- regmatches(ttl_output, gregexpr("urn:uuid:[a-f0-9-]+", ttl_output))[[1]]

  expect_equal(length(unique(uuids)), 2)
})
