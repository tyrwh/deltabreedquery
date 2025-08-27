library(httr2)

#' Build and execute generic GET request.
#'
#' @description Makes authenticated GET requests to a BrAPI endpoint and handles
#' pagination automatically. Returns parsed JSON data from all pages.
#' @param url Character string. The API endpoint URL to request data from.
#' @param token Character string. The authentication bearer token.
#' @param page_size Integer. Number of records to request per page. Default is 500.
#' @return A list of parsed JSON responses from all pages.
#' @details This function handles pagination automatically by making additional
#' requests if the total number of records exceeds the page size. It includes
#' custom error handling for common HTTP status codes (401, 404, 405) with
#' helpful error messages for troubleshooting authentication and endpoint issues.
get_url_to_json <- function(base_url, endpoint, token, page_size = 1000, verbose = TRUE){
  url <- build_brapi_url(base_url, endpoint)
  # build an empty request
  req <- request(url) |>
    req_url_query(pageSize = page_size) |>
    req_auth_bearer_token(token) |>
    req_error(is_error = function(resp) {
      # Custom error messages to help people troubleshoot
      if (resp_status(resp) == 401) {
        stop("Status code: ", resp_status(resp),
             "\nAccess Token rejected by BrAPI endpoint. ",
             " Please double-check that your BrAPI URL is correct",
             " and try regenerating the Access Token.")
      } else if (resp_status(resp) %in% c(404, 404, 405)) {
        stop("Status code: ", resp_status(resp),
             "\nSpecified BrAPI endpoint not found." ,
             " Please double-check that your BrAPI URL is correct.",
             " If this issue persists, please contact the package maintainers.")
      } 
      resp_status(resp) != 200})

  # perform the first request and validate it
  response <- req_perform(req)
  json <- response |>
    resp_body_json(simplifyVector = TRUE,
                   flatten = TRUE)
  n_records <- json$metadata$pagination$totalCount

  # Check response status
  if (n_records == 0) {
    stop("API call was successful but 0 records were found.")
  }
  # iterate through pages if necessary
  # a little clunky here - might be a better way to iterate through n+1 remaining pages
  if (verbose) cat("Number of records found: ", n_records, "\n")
  responses <- list(response)
  if (n_records > page_size) {
    n_pages <- ceiling(n_records / page_size)
    further_responses <- req_perform_iterative(req,
                                       iterate_with_offset("page"),
                                       max_reqs = n_pages-1)
    responses <- c(responses, further_responses)
  }
  json <- lapply(responses, function(x) resp_body_json(x,
                                                     simplifyVector = TRUE,
                                                     flatten = TRUE))
  json
}
