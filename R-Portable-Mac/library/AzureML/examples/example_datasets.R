\dontrun{
  library(AzureML)
  
  # Use the default config file ~/azureml/settings.json with format:
  #   {"workspace":{
  #     "id":"test_id",
  #     "authorization_token": "test_token",
  #     "api_endpoint":"api_endpoint",
  #     "management_endpoint":"management_endpoint"
  #    }}
  # or, optionally set the `id` and `auth` parameters in the workspace
  # function.
  ws <- workspace()
  
  # List datasets
  ws$datasets
  datasets(ws)
  
  dataset <- "New York weather"
  ds <- match(dataset, ws$datasets$Name)
  frame <- download.datasets(ws$datasets[ds, ])
  head(frame)

  # Alternative approach:
  frame <- download.datasets(ws, name=dataset)
  head(frame)
}
