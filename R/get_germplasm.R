library(httr2)
library(dplyr)

#' Get Germplasm Data
#'
#' @description Retrieves germplasm data from the BrAPI endpoint
#' @return Germplasm data from the BrAPI API
#' @export
#' @examples
#' \dontrun{
#' get_germplasm()
#' }
get_germplasm <- function() {
  # Check if auth fields have been set
  if (!auth_exists()) {
    stop("No authentication credentials found. ",
         "Please run `login_deltabreed()` to authenticate first.")
  }
  # Get global environment
  env <- get("deltabreedr_global", envir = .GlobalEnv)
  # send request and build list of json responses
  json <- get_url_to_json(env$brapi_url, "germplasm", env$access_token)
  dfs <- lapply(json, clean_json_germplasm)
  df <- bind_rows(dfs)
  cat("Number of records pulled: ", nrow(df), "\n")
  df
}

clean_json_germplasm <- function(json) {
  data = json$result$data
  # account for empty responses, if any occur
  if (length(data) == 0){
    return(data.frame())
  }
  data |>
    rename(GID = accessionNumber,
           GermplasmName = germplasmName,
           BreedingMethod = additionalInfo.breedingMethod,
           Source = seedSource,
           Pedigree = additionalInfo.pedigreeByName,
           CreatedDate = additionalInfo.createdDate,
           CreatedBy = additionalInfo.createdBy.userName) |>
    select(GID, GermplasmName, BreedingMethod,
           Source, Pedigree,
           CreatedDate, CreatedBy) |>
    arrange(as.integer(GID))
}