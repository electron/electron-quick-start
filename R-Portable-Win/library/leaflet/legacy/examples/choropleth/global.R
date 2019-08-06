density <- c(
  "Alabama" = 94.65,
  "Arizona" = 57.05,
  "Arkansas" = 56.43,
  "California" = 241.7,
  "Colorado" = 49.33,
  "Connecticut" = 739.1,
  "Delaware" = 464.3,
  "District of Columbia" = 10065,
  "Florida" = 353.4,
  "Georgia" = 169.5,
  "Idaho" = 19.15,
  "Illinois" = 231.5,
  "Indiana" = 181.7,
  "Iowa" = 54.81,
  "Kansas" = 35.09,
  "Kentucky" = 110,
  "Louisiana" = 105,
  "Maine" = 43.04,
  "Maryland" = 596.3,
  "Massachusetts" = 840.2,
  "Michigan" = 173.9,
  "Minnesota" = 67.14,
  "Mississippi" = 63.50,
  "Missouri" = 87.26,
  "Montana" = 6.858,
  "Nebraska" = 23.97,
  "Nevada" = 24.80,
  "New Hampshire" = 147,
  "New Jersey" = 1189,
  "New Mexico" = 17.16,
  "New York" = 412.3,
  "North Carolina" = 198.2,
  "North Dakota" = 9.916,
  "Ohio" = 281.9,
  "Oklahoma" = 55.22,
  "Oregon" = 40.33,
  "Pennsylvania" = 284.3,
  "Rhode Island" = 1006,
  "South Carolina" = 155.4,
  "South Dakota" = 98.07,
  "Tennessee" = 88.08,
  "Texas" = 98.07,
  "Utah" = 34.30,
  "Vermont" = 67.73,
  "Virginia" = 204.5,
  "Washington" = 102.6,
  "West Virginia" = 77.06,
  "Wisconsin" = 105.2,
  "Wyoming" = 5.851
)

# Breaks we'll use for coloring
densityBreaks <- c(0, 10, 20, 50, 100, 200, 500, 1000, Inf)
# Construct break ranges for displaying in the legend
densityRanges <- data.frame(
  from = head(densityBreaks, length(densityBreaks) - 1),
  to = tail(densityBreaks, length(densityBreaks) - 1)
)

# Eight colors for eight buckets
palette <- c("#FFEDA0", "#FED976", "#FEB24C", "#FD8D3C",
             "#FC4E2A", "#E31A1C", "#BD0026", "#800026")
# Assign colors to states
colors <- structure(
  palette[cut(density, densityBreaks)],
  names = tolower(names(density))
)

# The state names that come back from the maps package's state database has
# state:qualifier format. This function strips off the qualifier.
getStateName <- function(id) {
  strsplit(id, ":")[[1]][1]
}
