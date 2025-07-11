#' DeltaBreed login and authentication
#'
#' Interactive function to add BrAPI base URL and access token from DeltaBreed.
#' 
#' @description This function prompts the user to enter a BrAPI Base URL and 
#' Access Token, then stores them in the global package environment for use
#' in subsequent API calls.
#'
#' @return No return value, called for side effects (storing credentials)
#' @export
#' @examples#' \dontrun{
#' login_deltabreed()
#' }
login_deltabreed <- function(url = NULL) {
  # Prompt for BrAPI Base URL
  cat("=== DeltaBreed Login and Authentication ===\n")
  if (!is.null(url)) {
    brapi_url <- url
  } else {
    cat("Please enter the BrAPI Base URL. This can be found on the BrAPI tab")
    cat(" of DeltaBreed, under the 'BrAPI Information' pane at left.\n")
    brapi_url <- readline(prompt = "BrAPI Base URL: ")
  }
  # Validate URL input
  if (nchar(trimws(brapi_url)) == 0) {
    stop("BrAPI Base URL cannot be empty")
  }
  # Clean up URL (remove trailing slash if present)
  brapi_url <- sub("/$", "", trimws(brapi_url))

  # Prompt for Access Token
  cat("\nPlease generate an Access Token from the BrAPI tab of DeltaBreed.\n")
  access_token <- readline(prompt = "Access Token: ")
  # Validate token input
  if (nchar(trimws(access_token)) == 0) {
    stop("Access Token cannot be empty")
  }

  # Test authentication by making a test API call
  cat("\nTesting authentication...\n")
  test_url <- paste0(brapi_url, "/brapi/v2/programs")
  response <- httr::GET(
    test_url,
    httr::add_headers(Authorization = paste("Bearer", access_token))
  )
  if (httr::status_code(response) == 200) {
    cat("URL and Access Token validated!\n")
    cat("Program name: ",
        jsonlite::fromJSON(rawToChar(response$content))$result$data$programName,
        "\n")
    # if authentication is successful, store credentials in global environment
    # Initialize global environment if it doesn't exist
    if (!exists("deltabreedr_global", envir = .GlobalEnv)) {
      assign("deltabreedr_global", new.env(), envir = .GlobalEnv)
    }
    deltabreedr_global$brapi_url <- brapi_url
    deltabreedr_global$access_token <- access_token
    deltabreedr_global$login_timestamp <- Sys.time()
  } else if (httr::status_code(response) == 401) {
    stop("401: Access Token not accepted. ",
         "Please double-check the BrAPI Base URL and ",
         "try generating a new Access Token.")
  } else if (httr::status_code(response) == 404) {
    stop("404: BrAPI endpoint not found. ",
         "Please double-check the BrAPI Base URL.")
  } else {
    stop("Unexpected error during authentication test. Status code: ",
         httr::status_code(response))
  }
  invisible(TRUE)
}

#' Clear DeltaBreed authentication credentials
#'
#' @description Removes stored credentials from the global environment
#' @return No return value, called for side effects (clearing credentials)
#' @export
logout_deltabreed <- function() {
  if (exists("deltabreedr_global", envir = .GlobalEnv)) {
    env <- get("deltabreedr_global", envir = .GlobalEnv)
    if (exists("brapi_url", envir = env)) rm("brapi_url", envir = env)
    if (exists("access_token", envir = env)) rm("access_token", envir = env)
  }
  
  cat("✓ Credentials cleared successfully.\n")
  invisible(TRUE)
}

#' Check if url and access token exist in the global environment
#'
#' @description Checks if the user has credential strings
#' @return Logical value indicating if user is authenticated
auth_exists <- function() {
  if (!exists("deltabreedr_global", envir = .GlobalEnv)) {
    return(FALSE)
  }
  env <- get("deltabreedr_global", envir = .GlobalEnv)
  if (!exists("brapi_url", envir = env) || 
      !exists("access_token", envir = env)) {
    return(FALSE)
  }
  return(TRUE)
}

#' Check and report DeltaBreed authentication status
#'
#' @description Checks if the user is logged in and prints a message.
#' Also prints the remaining time until the access token expires, if available.
#' @return No return value, called for side effects (printing status)
#' @export
check_auth <- function() {
  if (auth_exists()) {
    cat("✓ You are logged in to DeltaBreed.\n")
    # Check for login timestamp and print remaining time (assuming 24h expiry)
    env <- get("deltabreedr_global", envir = .GlobalEnv)
    if (exists("login_timestamp", envir = env)) {
      login_time <- env$login_timestamp
      expiry_time <- login_time + 24 * 60 * 60
      now <- Sys.time()
      remaining <- as.numeric(difftime(expiry_time, now, units = "secs"))
      if (remaining > 0) {
        hours <- floor(remaining / 3600)
        minutes <- floor((remaining %% 3600) / 60)
        cat(sprintf("Access token expires in %d hours %d minutes.\n", hours, minutes))
        # Check if program information is accessible
        test_url <- paste0(env$brapi_url, "/brapi/v2/programs")
        response <- httr::GET(
          test_url,
          httr::add_headers(Authorization = paste("Bearer", env$access_token))
        )
        if (httr::status_code(response) == 200) {
          cat("Program name: ",
              jsonlite::fromJSON(rawToChar(response$content))$result$data$programName,
              "\n")
        }
      } else {
        cat("Access token has expired. Please re-authenticate.\n")
      }
    }
  } else {
    cat("✗ You are not logged in. Please run login_deltabreed() to authenticate.\n")
  }
  invisible(TRUE)
}
