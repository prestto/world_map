# This file shows an example of all (english) conversions for country codes
library(countrycode)

# Dirty sample
sample_coutry_list <- tibble(orig_country =
c("Afghanistan", "Albania", "Algeria", "Andorra", "Angola", "Anguilla", 
  "Antigua and Barbuda", "Argentina", "Armenia", "Aruba", "Australia", 
  "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", 
  "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bhutan", 
  "Bolivia", "Bosnia-Herzegovina", "Botswana", "Brazil", "Brunei", 
  "Bulgaria", "Burkina Faso", "Burundi", "Côte d'Ivoire", "Cambodia", 
  "Cameroon", "Canada", "Cayman Islands", "Central African Republic", 
  "Chad", "Chile", "China", "Colombia", "Comoros", "Costa Rica", 
  "Croatia", "Cuba", "Cyprus", "Czech Republic", "Denmark", "Djibouti", 
  "Dominica", "Dominican Republic", "Ecuador", "Egypt", "El Salvador", 
  "Eritrea", "Estonia", "Ethiopia", "Fiji", "Finland", "France", 
  "French Polynesia", "Gabon", "Gambia", "Georgia", "Germany", 
  "Ghana", "Gibraltar", "Greece", "Greenland", "Grenada", "Guatemala", 
  "Guinea", "Guyana", "Honduras", "Hong Kong", "Hungary", "Iceland", 
  "India", "Indonesia", "Iran", "Ireland", "Israel", "Italy", "Jamaica", 
  "Japan", "Jordan", "Kazakhstan", "Kenya", "Korea, Rep.", "Kuwait", 
  "Kyrgyzstan", "Laos", "Latvia", "Lebanon", "Lesotho", "Liberia", 
  "Libya", "Lithuania", "Luxembourg", "Macau", "Macedonia", "Madagascar", 
  "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Mauritania", 
  "Mauritius", "Mexico", "Micronesia", "Moldova", "Monaco", "Mongolia", 
  "Montserrat", "Morocco", "Mozambique", "Myanmar", "Namibia", 
  "Netherlands", "Netherlands Antilles", "New Caledonia", "New Zealand ", 
  "Nicaragua", "Niger", "Nigeria", "Norway", "Oman", "Pakistan", 
  "Palau", "Palestinian Territory", "Panama", "Papua New Guinea", 
  "Paraguay", "Peru", "Philippines", "Poland", "Portugal", "Qatar", 
  "Romania", "Russia", "Rwanda", "Saint Kitts and Nevis", "Saint Lucia", 
  "Saint Vincent and the Grenadines", "Samoa", "Saudi Arabia", 
  "Senegal", "Serbia", "Seychelles", "Sierra Leone", "Singapore", 
  "Slovak Republic", "Slovenia", "South Africa", "Spain", "Sri Lanka", 
  "Sudan", "Suriname", "Swaziland", "Sweden", "Switzerland", "Syria", 
  "Taiwan", "Tajikistan", "Tanzania", "Thailand", "Togo", "Tonga", 
  "Trinidad and Tobago", "Tunisia", "Turkey", "Turkmenistan", "Turks and Caicos Islands", 
  "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom", 
  "United States", "Uruguay", "Uzbekistan", "Venezuela", "Vietnam", 
  "Virgin Islands (U.K.)", "Yemen", "Zambia", "Zimbabwe"))

# List comparing all types of standards
list_of_countries <- sample_coutry_list %>%
  mutate(country.name = countrycode(orig_country, origin = "country.name", destination = "country.name"),
         ar5 = countrycode(orig_country, origin = "country.name", destination = "ar5"),
         cowc = countrycode(orig_country, origin = "country.name", destination = "cowc"),
         cown = countrycode(orig_country, origin = "country.name", destination = "cown"),
         eurostat = countrycode(orig_country, origin = "country.name", destination = "eurostat"),
         eu28 = countrycode(orig_country, origin = "country.name", destination = "eu28"),
         eurocontrol_pru = countrycode(orig_country, origin = "country.name", destination = "eurocontrol_pru"),
         eurocontrol_statfor = countrycode(orig_country, origin = "country.name", destination = "eurocontrol_statfor"),
         fao = countrycode(orig_country, origin = "country.name", destination = "fao"),
         fips105 = countrycode(orig_country, origin = "country.name", destination = "fips105"),
         icao = countrycode(orig_country, origin = "country.name", destination = "icao"),
         imf = countrycode(orig_country, origin = "country.name", destination = "imf"),
         ioc = countrycode(orig_country, origin = "country.name", destination = "ioc"),
         iso2c = countrycode(orig_country, origin = "country.name", destination = "iso2c"),
         iso3c = countrycode(orig_country, origin = "country.name", destination = "iso3c"),
         iso3n = countrycode(orig_country, origin = "country.name", destination = "iso3n"),
         p4_ccode = countrycode(orig_country, origin = "country.name", destination = "p4_ccode"),
         p4_scode = countrycode(orig_country, origin = "country.name", destination = "p4_scode"),
         un = countrycode(orig_country, origin = "country.name", destination = "un"),
         wb = countrycode(orig_country, origin = "country.name", destination = "wb"),
         wb_api2c = countrycode(orig_country, origin = "country.name", destination = "wb_api2c"),
         wb_api3c = countrycode(orig_country, origin = "country.name", destination = "wb_api3c"),
         wvs = countrycode(orig_country, origin = "country.name", destination = "wvs")
  )

# create list of all country names, and their corresponding Iso3 codes
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
  arrange(n_code)