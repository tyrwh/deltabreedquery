test_that("R instance can connect to server at all", {
  req <- request("https://test-server.brapi.org/brapi/v2/germplasm")
  resp <- req_perform(req)
  expect_equal(resp_status(resp), 200)
  rm(req, resp)
})

test_that("BrAPI endpoint URLs are constructed correctly", {
  base_url <-"https://test-server.brapi.org"
  url <- build_brapi_url(base_url, endpoint = "germplasm")
  req <- request(url)
  resp <- req_perform(req)
  json <- resp |>
    resp_body_json(simplifyVector = TRUE,
                   flatten = TRUE)
  expect_equal(resp_status(resp), 200)
  expect_equal(json$metadata$pagination$totalCount, 3)
  rm(base_url, url, req, resp, json)
})

