library(httr)

# 1. Find OAuth settings for vimeo:
#    http://vimeo.com/api/docs/authentication
oauth_endpoints("vimeo")

# 2. Register an application at https://developer.vimeo.com/apps
#    Replace key and secret below.
myapp <- oauth_app("vimeo",
  key = "bd535bc38ed5caccd79330ff33075eb9",
  secret = "51ab8cb2cbb8b7eb")

# 3. Get OAuth credentials
vimeo_token <- oauth1.0_token(oauth_endpoints("vimeo"), myapp)

# 4. Use API
req <- GET("https://vimeo.com/api/rest/v2",
  query = list(method = "vimeo.videos.getAll", format = "json"),
  config(token = vimeo_token))
stop_for_status(req)
str(content(req))
