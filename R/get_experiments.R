library(httr2)
library(dplyr)
#' Get experiment data
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
  env <- get("deltabreedr_global", envir = .GlobalEnv)

  # send GET requests and clean the JSON responses
  json_trials <- execute_get_request(env$full_url, env$access_token,
                                     'trials', verbose = FALSE)
  json_studies <- execute_get_request(env$full_url, env$access_token,
                                      'studies', verbose = FALSE)
  df_trials <- bind_rows(lapply(json_trials, clean_json_trials))
  df_studies <- bind_rows(lapply(json_studies, clean_json_studies))

  cat("Number of Experiments found:  ", nrow(df_trials), "\n")
  cat("Number of Environments found: ", nrow(df_studies), "\n")

  # merge entities
  df_expts <- merge(df_trials, df_studies,
                    by = "trialDbId", all.x = TRUE, all.y = TRUE) |>
    select(ExptName, ExptType, ObservationLevel,
           EnvName, Location, CreatedBy, CreatedDate) |>
    arrange(CreatedDate, ExptName, EnvName)

  # to pull the years, you need to individually query each seasonDbId I think?
  # TODO - figure that out so you can order by year first
  df_expts
}

# trials are the LARGER entity - "Experiment" in DeltaBreed nomenclature
clean_json_trials <- function(json) {
  data = json$result$data
  if (length(data) == 0){
    return(data.frame())
  }
  data |>
    rename(ExptName = trialName,
           ExptType = additionalInfo.experimentType,
           ObservationLevel = additionalInfo.defaultObservationLevel,
           CreatedBy = additionalInfo.createdBy.userName,
           CreatedDate = additionalInfo.createdDate) |>
    select(ExptName, ExptType,
           ObservationLevel, CreatedBy, CreatedDate, trialDbId)
}

# studies are the SMALLER entity - "Environment" in DeltaBreed nomenclature
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
