# install.packages("sfdep")
# install.packages("osmdata")

library(tidyverse)
library(sf)
library(sfdep)
library(osmdata)
# library(igraph)

estaciones <- read_sf("https://cdn.buenosaires.gob.ar/datosabiertos/datasets/sbase/subte-estaciones/estaciones-de-subte.geojson") %>% 
  janitor::clean_names() %>% 
  glimpse()

st_crs(estaciones)

#Spatial autocorrelation 
# Moran I https://r.iresmi.net/posts/2023/spatial_autocorrelation/index.html


#Calcular distancias entre estaciones mas cercanas de la misma linea

#Test linea E

data <- estaciones %>% 
  filter(linea == "A") %>% 
  glimpse() %>% 
  print()

distances <- st_distance(data)
distances

max_distances <- max(distances)
max_distances

max_indices <- as.data.frame(which(distances == max_distances, arr.ind = TRUE))[,2]
max_indices

#Creo necesito la matriz completa, ordenar y extraer los indices de los valores en 
## diagonal. 
#Posiblemente esto solo sirva para ordenar, o incluso tenga que reemplazarlo 
##por dikjstra con las calles para calcular distancias reales. 
#De todos modos estaria bueno poner lineas en un mapa de este mismo. 

final_distances <- as.data.frame(units::drop_units(distances),row.names = TRUE) %>% 
  rownames_to_column() %>% 
  mutate(rowname = as.numeric(rowname)) %>%
  # # arrange(V14) %>% 
  # arrange(paste0("V",max_indices[1])) %>%
  # select(rowname, paste0("V",max_indices[1]), paste0("V",max_indices[2]) ) %>%
  glimpse() 
  print()

print(final_distances)
glimpse(final_distances)
class(final_distances)

class(distances)
  select(max_indices[1,2]) %>% 
  glimpse()
  arrange(as.integer(max_indices[1,2])) %>% 


# dt <- st_distance(Atest[1,4],Atest[2,4])
# class(dt)
# as.double(dt)
# distance_df <- data.frame(id = NA,
#                           distancia = NA)
# 
# for (i in 1:nrow(data)) {
#   
#   geom1 <- data$geometry[i]
#   print(geom1)
#   id <- data$id[i]
#   
#   if (i >= nrow(data)) {
#     break
#     
#   } else {
#     
#     geom2 <- data$geometry[i+1]
#     # print(geom2)
#     distance <- st_distance(x = geom1, y = geom2)
#     print(distance)
#     distance_df <- distance_df %>% 
#       add_row(id = id, 
#               distancia = as.double(distance))
#   }
# }
# 
# 
# data_final <- inner_join(data, distance_df) %>% 
#   glimpse()
# glimpse(distance_df)

###### igraph sofw
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