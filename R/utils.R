# Utility functions for deltabreedr package

#' Build BrAPI URL.
#'
#' @description Internal function to construct BrAPI v2 endpoint URLs
#' @param url Character string specifying the BrAPI Base URL as given by DeltaBreed
#' @param endpoint Character string specifying the endpoint (e.g., "germplasm", "programs")
#' @return Character string with the full BrAPI v2 endpoint path
#' @keywords internal
build_brapi_url <- function(url, endpoint) {
  paste0(url, "/brapi/v2/", endpoint)
}
