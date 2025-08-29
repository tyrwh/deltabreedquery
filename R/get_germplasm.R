library(httr2)
library(dplyr)

#' Get germplasm data
#'
#' @description Retrieves all germplasm data from the current DeltaBreed instance.
#' @return Germplasm data from the BrAPI API
#' @export
#' @examples
#' \dontrun{
#' login_deltabreed()
#' germplasm <- get_germplasm()
#' }
get_germplasm <- function() {
  if (!auth_exists()) {
    stop("No authentication credentials found. ",
         "Please run `login_deltabreed()` to authenticate first.")
  }
  env <- get("deltabreedr_global", envir = .GlobalEnv)

  # send GET request and clean JSON responses
  json <- execute_get_request(env$full_url, env$access_token, "germplasm")
  dfs <- lapply(json, clean_json_germplasm)
  df <- bind_rows(dfs)
  cat("Number of records found: ", nrow(df), "\n")
  df
}


clean_json_germplasm <- function(json) {
  data <- json$result$data
  # account for empty responses, if any occur
  if (length(data) == 0){
    return(data.frame())
  }
  rename_brapi_columns(data, 'germplasm') |>
    select(GID, GermplasmName, BreedingMethod,
           Source, Pedigree,
           CreatedDate, CreatedBy) |>
    arrange(as.integer(GID))
}

