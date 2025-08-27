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
  target_cols = c(
    'accessionNumber',
    'germplasmName',
    'additionalInfo.breedingMethod',
    'seedSource',
    'additionalInfo.pedigreeByName',
    'additionalInfo.createdDate',
    'additionalInfo.createdBy.userName'
  )
  data <- json$result$data
  # account for empty responses, if any occur
  if (length(data) == 0){
    return(data.frame())
  }
  data <- add_columns_to_match(data, target_cols)
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
