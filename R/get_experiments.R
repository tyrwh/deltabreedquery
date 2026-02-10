#' Get experiment data
#'
#' Retrieves the list of all experiments and environments in a DeltaBreed program.
#'
#' @return Data frame of experiment information drawn from BrAPI endpoints.
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
  json_seasons <- execute_get_request(env$full_url, env$access_token,
                                      'seasons', verbose = FALSE)

  df_trials <- dplyr::bind_rows(lapply(json_trials, clean_json_trials))
  df_studies <- dplyr::bind_rows(lapply(json_studies, clean_json_studies))
  df_seasons <- dplyr::bind_rows(lapply(json_seasons, clean_json_seasons))

  cat("Number of Experiments found:  ", nrow(df_trials), "\n")
  cat("Number of Environments found: ", nrow(df_studies), "\n")

  # merge entities
  df_studies <- dplyr::left_join(df_studies, df_seasons,
                                 by = join_by(seasons == seasonDbId)) |>
    select(!seasons)
  df_expts <- dplyr::full_join(df_trials, df_studies,
                               by = "trialDbId") |>
    dplyr::select(ExptName, ExptType, EnvName, Location, Year,
                  ObservationLevel,
                  CreatedBy, CreatedDate) |>
    dplyr::arrange(Year, ExptName, EnvName)

  # TODO - when they implement multiple seasons (for long lived perennials)
  # revisit this to add support for multi-year cycles
  df_expts
}

# trials are the LARGER entity - "Experiment" in DeltaBreed nomenclature
clean_json_trials <- function(json) {
  data = json$result$data
  if (length(data) == 0){
    return(data.frame())
  }
  rename_brapi_columns(data, 'trials') |>
    dplyr::select(ExptName, ExptType,
                  ObservationLevel, CreatedBy, CreatedDate, trialDbId)
}

# studies are the SMALLER entity - "Environment" in DeltaBreed nomenclature
# Until multi-season environments are implemented, delist() should work
clean_json_studies <- function(json) {
  data = json$result$data
  if (length(data) == 0){
    return(data.frame())
  }
  rename_brapi_columns(data, 'studies') |>
    dplyr::mutate(seasons = unlist(seasons)) |>
    dplyr::select(EnvName, Location, Active,
                  studyDbId, trialDbId, seasons)
}

# Seasons endpoint just has all the years as seasons
clean_json_seasons <- function(json) {
  data = json$result$data
  if (length(data) == 0){
    return(data.frame())
  }
  data |>
    dplyr::select(seasonDbId, year) |>
    dplyr::rename(Year = year)
}
