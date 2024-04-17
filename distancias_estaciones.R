# install.packages("sfdep")
# install.packages("osmdata")
# install.packages('tidytransit')

library(tidyverse)
library(sf)
library(sfdep)
library(osmdata)
# library(tidytransit)
# library(igraph)

estaciones <- read_sf("https://cdn.buenosaires.gob.ar/datosabiertos/datasets/sbase/subte-estaciones/estaciones-de-subte.geojson") %>% 
  janitor::clean_names() %>% 
  glimpse()

st_crs(estaciones)

#Spatial autocorrelation 
# Moran I https://r.iresmi.net/posts/2023/spatial_autocorrelation/index.html
# Later .-

#Calcular distancias entre estaciones mas cercanas de la misma linea

#Test linea A

data <- estaciones %>% 
  filter(linea == "A") %>%
  glimpse() %>% 
  print()

distancias <- st_distance(data)
distancias[1:18,1:6]
view(dist)


distancias.max <- max(distancias)
distancias.max

#Me quedo con los indices de las filas 
indices.max <- as.data.frame(which(distancias == distancias.max, arr.ind = TRUE))[,1]
indices.max

#Vuelvo al dataset original 

cabeceras <- data %>% 
  slice(indices.max) %>% 
  print()

data

#Data reordenada cabeceras. aun queda desordena dos intermedias
data1 <- data %>% 
  slice(-indices.max) %>% 
  add_row(cabeceras[1,]) %>% 
  add_row(cabeceras[2,], .before = 1) %>% 
  print()

distancias1 <- st_distance(data1)
distancias1[1:18,1:6]
view(distancias1)

data1 <- data %>% 
  slice(-indices.max) %>% 
  add_row(cabeceras[1,]) %>% 
  add_row(cabeceras[2,], .before = 1) %>% 
  print()

distancias1 <- st_distance(data1)
distancias1[1:18,1:6]
view(distancias1)
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

# class(distances)
  # select(max_indices[1,2]) %>% 
  # glimpse()
  # arrange(as.integer(max_indices[1,2]))

#Dijkstra igraph test ####
# https://rstudio-pubs-static.s3.amazonaws.com/771577_dbc6caf1be084434928f3249ccd40c00.html

# g_dist <- graph_from_adjacency_matrix(dist, mode = "undirected", weighted = TRUE)
# g_dist
# 
# V(g_dist)$color = 2
# E(g_dist)$color = 2
# 
# plot(g_dist, edge.label = E(g_dist)$weight)
# 
# sp_dist <- shortest_paths(g_dist, 1, to = V(g_dist))$vpath[[10]]


####
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