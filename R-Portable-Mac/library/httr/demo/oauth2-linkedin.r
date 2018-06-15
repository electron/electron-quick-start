library(httr)

# 1. Find OAuth settings for linkedin:
#    https://developer.linkedin.com/documents/linkedins-oauth-details
oauth_endpoints("linkedin")

# 2. Register an application at https://www.linkedin.com/secure/developer
#    Make sure to register http://localhost:1410/ as an "OAuth 2.0 Redirect URL".
#    (the trailing slash is important!)
#
#    Replace key and secret below.
myapp <- oauth_app("linkedin",
  key = "outmkw3859gy",
  secret = "n7vBr3lokGOCDKCd")

# 3. Get OAuth credentials
# LinkedIn doesn't implement OAuth 2.0 standard
# (http://tools.ietf.org/html/rfc6750#section-2) so we extend the Token2.0
# ref class to implement a custom sign method.
TokenLinkedIn <- R6::R6Class("TokenLinkedIn", inherit = Token2.0, list(
  sign = function(method, url) {
    url <- parse_url(url)
    url$query$oauth2_access_token <- self$credentials$access_token
    request(url = build_url(url))
  },
  can_refresh = function() {
    TRUE
  },
  refresh = function() {
    self$credentials <- init_oauth2.0(self$endpoint, self$app,
      scope = self$params$scope, type = self$params$type,
      use_oob = self$params$use_oob)
  }
))
token <- TokenLinkedIn$new(
  endpoint = oauth_endpoints("linkedin"),
  app = myapp,
  params = list(use_oob = FALSE, scope = NULL, type = NULL)
)

# 4. Use API
req <- GET("https://api.linkedin.com/v1/people/~", config(token = token))
stop_for_status(req)
content(req)
