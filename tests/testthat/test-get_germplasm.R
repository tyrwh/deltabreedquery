test_that("parsing works", {
  url_testserver = "https://test-server.brapi.org/brapi"
  f = system.file('germplasm.json', package='deltabreedquery')
  json = jsonlite::fromJSON(f,
                            simplifyVector = TRUE,
                            flatten = TRUE)
  df = clean_json_germplasm(json)
  expect_equal(nrow(json$result$data), 50)
  expect_equal(nrow(df), 50)
})

test_that("get_germplasm() output matches expected format", {
  assign("deltabreedr_global", new.env(), envir = .GlobalEnv)
  deltabreedr_global$brapi_url = "https://test-server.brapi.org"
  deltabreedr_global$access_token = ""
  get_germplasm()
})
