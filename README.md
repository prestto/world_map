# world_map
This was my first spatial challenge in r. The project involved plotting calls arriving or origniating from one location, at a country level.

Three data sources were used:
 - An external call volume database (dummy data here)
 - Information from natural earth data (http://www.naturalearthdata.com/downloads/10m-cultural-vectors/10m-populated-places/)
 - A list of countries and their centroids (https://developers.google.com/public-data/docs/canonical/countries_csv)

Challenges included:
 - Dealing with country names from 3 different data sources
 - Working with maps in ggplot2 (overlaying multiple polygons/ paths)
 - Centring a map on a country, and adjusting overlaying shapes to compensate
