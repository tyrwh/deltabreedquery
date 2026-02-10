\name{delta_login}
\alias{delta_login}
\title{Delta Login Function}
\usage{
delta_login()
}
\description{
Interactive function to authenticate with BrAPI and store credentials globally. This function prompts the user to enter a BrAPI Base URL and Access Token, then stores them in the global package environment for use in subsequent API calls.
}
\details{
This function creates or uses an existing global environment called \code{deltabreedquery_global} to store authentication credentials. The function will prompt for:

1. BrAPI Base URL - The base URL of your BrAPI-compliant database
2. Access Token - An authentication token obtained from your BrAPI provider

The credentials are stored as:
\itemize{
  \item \code{deltabreedquery_global$brapi_url} - The BrAPI base URL
  \item \code{deltabreedquery_global$access_token} - The access token
}
}
\value{
No return value, called for side effects (storing credentials). Returns \code{TRUE} invisibly on success.
}
\examples{
\dontrun{
# Interactive authentication
delta_login()

# Check authentication status
auth_status()

# Log out
delta_logout()
}
}
\seealso{
\code{\link{is_authenticated}}, \code{\link{auth_status}}, \code{\link{delta_logout}}
}
