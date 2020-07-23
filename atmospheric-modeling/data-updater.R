# Load libraries
library(DBI)
library(tidyverse)



# Download the Country List
countryList <- tempfile()
download.file("ftp://ftp.ncdc.noaa.gov/pub/data/igra/igra2-country-list.txt", countryList)

# Function to parse Country List
country_parser <- function(file, ...) {
  readr::read_fwf(
    file = file,
    col_positions = readr::fwf_positions(
      c(1,4),
      c(2,43),
      c("CODE","NAME")
    ),
    col_types = readr::cols(
      CODE = readr::col_character(),
      NAME = readr::col_character()
    )
  )
}

# Parse the Country List into memory
updatedCountryList <- country_parser(countryList)

# Establish database connection
con <- dbConnect(RPostgres::Postgres(), 
                 user = "postgres",
                 dbname = "noaa_igra"
)

# Left join the latest data with the local database
currentCountryList <- dbGetQuery(con, '
           SELECT *
           FROM country_list
           ')

if (identical(currentCountryList, updatedCountryList) != TRUE) {
  dbWriteTable(con, 
               "country_list", 
               updatedCountryList,
               overwrite = TRUE)
}

# Close the database connection
dbDisconnect(con)