library(httr2)
library(dplyr)
#' Get Experiment Data
#'
#' @description Retrieves the list of all experiments in a DeltaBreed program.
#' @return Data frame of experiment information drawn from BrAPI endpoints
#' @export
#' @examples
#' \dontrun{
#' get_experiments()
#' }
get_experiments <- function(summarize = TRUE) {
  # Check if auth fields have been set
  if (!auth_exists()) {
    stop("No authentication credentials found. ",
         "Please run `login_deltabreed()` to authenticate first.")
  }
  # Get global environment
  env <- get("deltabreedr_global", envir = .GlobalEnv)
  # get trial and study data
  json_trials <- get_url_to_json(env$brapi_url, 'trials', env$access_token, verbose = FALSE)
  json_studies <- get_url_to_json(env$brapi_url, "studies", env$access_token, verbose = FALSE)
  df_trials <- bind_rows(lapply(json_trials, clean_json_trials))
  df_studies <- bind_rows(lapply(json_studies, clean_json_studies))

  cat("Number of experiments found:  ", nrow(df_trials), "\n")
  cat("Number of environments found: ", nrow(df_studies), "\n")

  # merge
  df_expts <- merge(df_trials, df_studies,
                      by = "trialDbId", all.x = TRUE, all.y = TRUE)

                    
  # to pull the seasons, you need to individually query each seasonDbId I think?

  # more thinking - maybe get the number of observations in each?

  df_expts
}

clean_json_trials <- function(json) {
  data = json$result$data
  if (length(data) == 0){
    return(data.frame())
  }
  data |>
    rename(ExptName = trialName,
    ExptType = additionalInfo.experimentType,
    ObservationLevel = additionalInfo.defaultObservationLevel,
    CreatedBy = additionalInfo.createdBy.userName) |>
    select(ExptName, ExptType,
           ObservationLevel, CreatedBy, trialDbId)
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
