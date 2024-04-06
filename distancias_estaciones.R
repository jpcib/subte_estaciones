library(tidyverse)
library(sf)

estaciones <- read_sf("https://cdn.buenosaires.gob.ar/datosabiertos/datasets/sbase/subte-estaciones/estaciones-de-subte.geojson") %>% 
  glimpse()

#Calcular distancias entre estaciones mas cercanas de la misma linea

estaciones %>% 
  group_by(LINEA) %>% 
  summarise(n = n())
