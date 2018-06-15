require(shiny)
require(visNetwork)

shinyServer(function(input, output) {
  
  source("./src/server/basic_server.R", local = TRUE, encoding = "UTF-8")
  source("./src/server/options_server.R", local = TRUE, encoding = "UTF-8")
  source("./src/server/manip_server.R", local = TRUE, encoding = "UTF-8")
  source("./src/server/proxy_nodes_server.R", local = TRUE, encoding = "UTF-8")
  source("./src/server/proxy_anim_server.R", local = TRUE, encoding = "UTF-8")
  source("./src/server/proxy_update_server.R", local = TRUE, encoding = "UTF-8")
  source("./src/server/proxy_options_server.R", local = TRUE, encoding = "UTF-8")
  source("./src/server/proxy_select_server.R", local = TRUE, encoding = "UTF-8")
  source("./src/server/proxy_get_server.R", local = TRUE, encoding = "UTF-8")
  source("./src/server/proxy_set_title_server.R", local = TRUE, encoding = "UTF-8")
})
