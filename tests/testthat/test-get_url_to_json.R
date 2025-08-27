
test_that("URLs handled with appropriate error codes", {
  # attempting access with no token should give 401
  url_401 = "https://rel-test.breedinginsight.net/v1/programs/21811e96-cf8c-4dc1-9084-d38c01355fc5"
  expect_error(get_url_to_json(url_401, 'germplasm', token = ''),
               "Access Token rejected")

  # attempting access to non-existent endpoint should return error with 404 message
  url_testserver = "https://test-server.brapi.org"
  expect_error(get_url_to_json(url_testserver, "foobar", token = ""),
               "BrAPI endpoint not found.")

  # attempting query of non-existent data should return error noting no results
  expect_error(get_url_to_json(url_testserver, "germplasm?accessionNumber=snarble", token = ""),
               "0 records were found.")
})

test_that("extracted JSONs are formatted correctly", {
  url_testserver = "https://test-server.brapi.org"
  # attempt two queries of endpoints to gauge if json formatting
  json_germ <- get_url_to_json(url_testserver, "germplasm", token = "", verbose = FALSE)
  json_obs <- get_url_to_json(url_testserver, "observations", token = "", verbose = FALSE)
  expect_equal(json_germ[[1]]$metadata$pagination$totalCount, 3)
  expect_equal(json_obs[[1]]$metadata$pagination$totalCount, 4)
})
