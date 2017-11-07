# Setup -------------
x <- c('tidyverse', 'xlsx', 'rJava', 'xlsxjars', 'stringr', 'readxl', 'countrycode', 'foreign')
sapply(X = x, FUN = require, character.only = TRUE)
options(java.parameters = "-Xmx1024m", scipen = 15)
rm(list=ls())

# Params -------------
route_path <-   'C:/Users/thomas.preston/Desktop/TestProjects/GlobalMins/Telegeography2017_Traffic_DB_Route.xlsx'

# Import route information ---------------------------------
routes_raw <- readxl::read_excel(route_path, sheet = 'traffic_db_route_export')

routes_raw[routes_raw=="-"] <- NA

calls_by_route <- routes_raw %>%
  dplyr::rename(orig_region = `Principal Region`,
                dest_region = `Correspondent Region`) %>%
  mutate(orig_country = toupper(`Principal Country`),
         dest_country = toupper(`Correspondent Country`)) %>%
  group_by(orig_country, orig_region, dest_country, dest_region) %>%
  gather(info, mins, 5:124) %>%
  mutate(year = str_extract(string = info, pattern = '(\\d){4}'),
         direction = if_else(grepl(info, pattern = 'Outgoing'), 'Outgoing', 'Incoming'),
         type = if_else(grepl(info, pattern = 'TDM'), 'GSM', 'VOIP'),
         mins = as.numeric(mins) * 1000000) %>%
  select(orig_region, orig_country, dest_region, dest_country, direction, type, year, mins) %>%
  arrange(orig_country, dest_country, type, year) %>%
  filter(!is.na(mins),
         year == "2015")

# Import capitals from the website in description----------
cities <- read.dbf("C:/Users/thomas.preston/Desktop/TestProjects/GlobalMins/ne_10m_populated_places/ne_10m_populated_places.dbf")

capital_cities <- cities %>%
  dplyr::rename(country_ci = ADM0NAME, city_ci = NAMEASCII, lat = LATITUDE, lon = LONGITUDE) %>%
  mutate(country_ci = trimws(toupper(country_ci)),
         city_ci = trimws(toupper(city_ci))) %>%
  filter(ADM0CAP == 1) %>%
  arrange(country_ci) %>%
  select(country_ci, city_ci, lat, lon)

################ Normalise the countries to iso3 codes ############----------------
# Recode unrecognised countries
calls_by_route$orig_country <- dplyr::recode(calls_by_route$orig_country, Micronesia = "Federated States of Micronesia", `RÃ©union` = "Réunion")
calls_by_route$dest_country <- dplyr::recode(calls_by_route$dest_country, Micronesia = "Federated States of Micronesia", `RÃ©union` = "Réunion")


# Create matching table with original names and match names
# We use a matching table as the countrycodes, as opposed to just adding a column directly, as the function itsself is very slow
country_conversion_table <- tibble(dirty_countries = unique(c(capital_cities$country_ci, 
                                                        calls_by_route$orig_country, 
                                                        calls_by_route$dest_country))) %>%
  mutate(n_code = countrycode(sourcevar = dirty_countries,
                              origin = "country.name",
                              destination = "iso3n"),
         c_code = countrycode(sourcevar = dirty_countries,
                              origin = "country.name",
                              destination = "iso3c")
  ) %>%
  arrange(dirty_countries)


print(paste('The following countries could not be matched: ', paste(unlist(country_conversion_table[is.na(country_conversion_table$c_code),][1]), collapse = ', ')))


# Merge the country codes with each table----------------------
# n_code_orig/c_code_orig/c_code_dest/c_code_dest
calls_by_route <- merge(x = calls_by_route, y = country_conversion_table[,c("dirty_countries", "n_code")], by.x = "orig_country", by.y = 'dirty_countries', all.x = TRUE)
calls_by_route <- merge(x = calls_by_route, y = country_conversion_table[,c("dirty_countries", "n_code")], by.x = "dest_country", by.y = 'dirty_countries', all.x = TRUE, suffixes = c("_orig", "_dest"))

capital_cities <- merge(x = capital_cities, y = country_conversion_table[,c("dirty_countries", "n_code")], by.x = "country_ci", by.y = 'dirty_countries', all.x = TRUE)

# Clean up ------------------
rm(list = c("route_path", "cities", "country_conversion_table", "routes_raw"))

# Calls by route
call_data <- merge(x = calls_by_route, y = capital_cities[,c("n_code", "city_ci", "lat", "lon")], by.x = "n_code_orig", by.y = "n_code", all.x = TRUE)
call_data <- merge(x = call_data, y = capital_cities[,c("n_code", "lat", "lon")], by.x = "n_code_dest", by.y = "n_code", all.x = TRUE, suffixes = c('_orig', '_dest'))

rm(list = c("capital_cities", "calls_by_route"))
