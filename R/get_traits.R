library(httr2)
library(dplyr)
#' Get trait data
#'
#' @description Retrieves trait data from a DeltaBreed program via BrAPI.
#' @return Data frame of trait information drawn from BrAPI endpoints
#' @export
#' @examples
#' \dontrun{
#' get_traits()
#' }

get_traits <- function(include_archived = FALSE) {
  # Check if auth fields have been set
  if (!auth_exists()) {
    stop("No authentication credentials found. ",
         "Please run `login_deltabreed()` to authenticate first.")
  }
  # Get global environment
  env <- get("deltabreedr_global", envir = .GlobalEnv)

  # pull trial and study data
  json_traits <- get_url_to_json(env$brapi_url, "variables", env$access_token, verbose = FALSE)
  dfs_traits <- lapply(json_traits, clean_json_traits)
  df <- bind_rows(dfs_traits)
  cat("Number of traits found: \t", nrow(df), "\n")
  if (!include_archived) {
    df <- df |> filter(Status != "archived")
    cat("Number of active traits: \t", nrow(df), "\n")
  }
  df
}

clean_json_traits <- function(json) {
  data = json$result$data
  if (length(data) == 0){
    return(data.frame())
  }
  data |>
    mutate(FullName = sapply(trait.synonyms, function(x) tail(x,1)),
    Synonyms = sapply(data$trait.synonyms,
       function(x) ifelse(length(x) > 2,
                          paste0(x[2:(length(x)-1)], collapse = ";"),
                          "")),
                          Categories = sapply(scale.validValues.categories, collapse_trait_categories)) |>
    rename(
      Name = observationVariableName,
      Entity = trait.entity,
      Attribute = trait.attribute,
      Method = method.methodClass,
      ScaleClass = scale.dataType,
      Units = scale.scaleName,
      Min = scale.validValues.min,
      Max = scale.validValues.max,
      Status = status
    ) |>
    select(Name, FullName, Synonyms, Entity, Attribute, Method, ScaleClass, Units, Min, Max, Categories, Status)
}

collapse_trait_categories <- function(df) {
  if (is.null(df)){
    out_str = ""
  } else {
    paired_labels = paste(df$value, df$label, sep = "=")
    out_str = paste(paired_labels, collapse = "; ")
  }
  out_str
}