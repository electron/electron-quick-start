\dontrun{
  library(AzureML)
  
  experiment <- "dd01c7e4a424432c9a9f83142d5cfec4.f-id.d2f351dd4cec4c06a4592ac83f7af55a"
  node_id <- '2a472ae1-ecb1-4f40-ae4e-cd3cecb1003f-268'
  
  ws <- workspace()
  
  ws$experiments
  experiments(ws)
  frame <- download.intermediate.dataset(ws, experiment, node_id,
                                         port_name = "Results dataset", 
                                         data_type_id = "GenericCSV")
  head(frame)
}
