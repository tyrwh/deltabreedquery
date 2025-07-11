library(httr2)
library(dplyr)
#' Get Observation data
#'
#' @description Retrieves observation data from a DeltaBreed program via BrAPI.
#' @return Observation data from the BrAPI API
#' @export
#' @examples
#' \dontrun{
#' get_observations()
#' }
get_observations <- function() {
  # Check if auth fields have been set
  if (!auth_exists()) {
    stop("No authentication credentials found. ",
         "Please run `login_deltabreed()` to authenticate first.")
  }
  # Get global environment
  env <- get("deltabreedr_global", envir = .GlobalEnv)

  # pull trial and study data
  json_obs <- get_url_to_json(env$brapi_url, "observations", env$access_token, verbose = FALSE)
  json_obsunits <- get_url_to_json(env$brapi_url, "observationunits", env$access_token, verbose = FALSE)

  dfs_trials <- lapply(json_trials, clean_json_trials)
  dfs_studies <- lapply(json_studies, clean_json_studies)
  df_trials <- bind_rows(dfs_trials)
  df_studies <- bind_rows(dfs_studies)
  # merge - this will be our return function for now
  df_obs <- merge(df_trials, df_studies,
                        by = "trialDbId", all.x = TRUE) |>
                      select(ExptName, ExptType, ObservationLevel,
                      EnvName, Location, Active,CreatedBy) |>
                      arrange(ExptName, EnvName, Location)

  cat("Number of observations found:  ", nrow(df_trials), "\n")
  cat("Number of environments found: ", nrow(df_studies), "\n")

  df_obs
}

clean_json_obsunits <- function(json) {
  data = json$result$data
  if (length(data) == 0){
    return(data.frame())
  }
  data |>
    rename(GermplasmName = germplasmName,
      Env = studyName,
      Expt = trialName,
      EnvLocation = locationName,
      ExpUnitID = observationUnitName,
      TestOrCheck = ) |>
      select(Env, Expt,
            EnvLocation, CreatedBy, trialDbId)
  }

clean_json_studies <- function(json) {
  data = json$result$data
  if (length(data) == 0){
    return(data.frame())
  }
  data |>
    rename(EnvName = studyName,
           Location = locationName,
           Active = active) |>
    select(EnvName, Location, Active,
           studyDbId, trialDbId)
}
