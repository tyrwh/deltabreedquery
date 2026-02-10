\name{auth_functions}
\alias{is_authenticated}
\alias{auth_status}
\alias{delta_logout}
\title{Authentication Helper Functions}
\usage{
is_authenticated()
auth_status()
delta_logout()
}
\description{
Helper functions for managing DeltaBreed Query authentication state.
}
\details{
\describe{
  \item{\code{is_authenticated()}}{Returns \code{TRUE} if valid credentials are stored, \code{FALSE} otherwise.}
  \item{\code{auth_status()}}{Displays current authentication status and masked credentials.}
  \item{\code{delta_logout()}}{Clears stored credentials from the global environment.}
}
}
\value{
\describe{
  \item{\code{is_authenticated()}}{Logical value indicating authentication status.}
  \item{\code{auth_status()}}{Returns \code{TRUE} invisibly if authenticated, \code{FALSE} otherwise.}
  \item{\code{delta_logout()}}{Returns \code{TRUE} invisibly after clearing credentials.}
}
}
\examples{
\dontrun{
# Login first
delta_login()

# Check if authenticated
if (is_authenticated()) {
  print("Ready to make API calls")
}

# View current status
auth_status()

# Logout when done
delta_logout()
}
}
\seealso{
\code{\link{delta_login}}
}
