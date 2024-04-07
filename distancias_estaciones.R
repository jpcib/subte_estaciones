library(tidyverse)
library(sf)
library(igraph)

estaciones <- read_sf("https://cdn.buenosaires.gob.ar/datosabiertos/datasets/sbase/subte-estaciones/estaciones-de-subte.geojson") %>% 
  janitor::clean_names() %>% 
  glimpse()

st_crs(estaciones)
#Calcular distancias entre estaciones mas cercanas de la misma linea

#Test linea E

data <- estaciones %>% 
  filter(linea == "A") %>% 
  glimpse() %>% 
  print()

-Atest[2,4]

dt <- st_distance(Atest[1,4],Atest[2,4])
class(dt)
as.double(dt)

distance_df <- data.frame(id = NA,
                          distancia = NA)

for (i in 1:nrow(data)) {
  
  geom1 <- data$geometry[i]
  print(geom1)
  
  if (i >= nrow(data)) {
    break
    
  } else {
    
    geom2 <- data$geometry[i+1]
    print(geom2)
    distance <- st_distance(x = geom1, y = geom2)
    distance_df <- distance_df %>% 
      add_row(id = i, 
              distancia = as.double(distance))
    
  }
}

glimpse(distance_df)
# group_st_distance <- function(data = NULL, geometry = data$geometry, group = NULL) {
#   for (i in geometry) {
#     
#   }
# }

# 
# 
# igraph::all_shortest_paths(Atest)
# 
# myShapefile <- readOGR(dsn=".", layer="MyShapefileName") # i.e. "MyShapefileName.shp"
# shpData <- readshpnw(myShapefile, ELComputed=TRUE)
# igraphShpObject <- nel2igraph(shpData[[2]], shpData[[3]], weight=shpData[[4]])
# testPath <- get.shortest.paths(igraphShpObject, from=42, to=52) # arbitrary nodes
# testPath[1] # print the node IDs to the console