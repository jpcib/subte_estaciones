# Ordenar estaciones a partir de distancias ####
# Versión consolidada de las pruebas del post. Todas las funciones de
# ordenamiento reciben un sf con las estaciones de UNA línea (en CRS métrico)
# y devuelven el mismo sf con las filas reordenadas.

library(tidyverse)
library(sf)

# Utilidades ####

matriz_distancias <- function(datos) {
  units::drop_units(st_distance(datos))
}

# Distancia entre cada estación y la siguiente, en el orden en que vienen las filas
distancias_consecutivas <- function(datos) {
  n <- nrow(datos)
  tibble(
    desde       = datos$estacion[-n],
    hasta       = datos$estacion[-1],
    distancia_m = as.numeric(st_distance(datos$geometry[-n], datos$geometry[-1], by_element = TRUE))
  )
}

# Largo total del recorrido: la vara para comparar métodos (más corto = más plausible)
longitud_recorrido <- function(datos) {
  sum(distancias_consecutivas(datos)$distancia_m)
}

# Prueba 2: cabeceras ####
# El par de estaciones más lejanas entre sí.
encontrar_cabeceras <- function(datos) {
  d <- matriz_distancias(datos)
  which(d == max(d), arr.ind = TRUE)[1, ] %>% unname()
}

# Prueba 3: distancia a una cabecera ####
ordenar_por_distancia_a_cabecera <- function(datos) {
  inicio <- encontrar_cabeceras(datos)[1]
  d <- matriz_distancias(datos)
  slice(datos, order(d[inicio, ]))
}

# Prueba 4: vecino más cercano ####
# Greedy: desde una cabecera, siempre a la estación más cercana no visitada.
ordenar_vecino_mas_cercano <- function(datos) {
  d <- matriz_distancias(datos)
  n <- nrow(d)
  recorrido <- encontrar_cabeceras(datos)[1]

  for (paso in seq_len(n - 1)) {
    actual     <- recorrido[length(recorrido)]
    candidatos <- setdiff(seq_len(n), recorrido)
    siguiente  <- candidatos[which.min(d[actual, candidatos])]
    recorrido  <- c(recorrido, siguiente)
  }

  slice(datos, recorrido)
}

# Prueba 5: PCA ####
# Proyecta las coordenadas sobre el eje de mayor varianza y ordena por ahí.
ordenar_pca <- function(datos) {
  pc1 <- prcomp(st_coordinates(datos))$x[, 1]
  slice(datos, order(pc1))
}

# Prueba 6: TSP de camino abierto ####
# Camino hamiltoniano más corto. Truco estándar: agregar una ciudad "ficticia"
# a distancia 0 de todas, resolver el circuito y cortarlo en ella.
ordenar_tsp <- function(datos, semilla = 1) {
  d <- matriz_distancias(datos)
  dimnames(d) <- list(seq_len(nrow(d)), seq_len(nrow(d)))

  tsp <- TSP::insert_dummy(TSP::TSP(as.dist(d)), label = "corte")

  set.seed(semilla)
  circuito <- TSP::solve_TSP(
    tsp,
    method  = "arbitrary_insertion",
    control = list(rep = 20, two_opt = TRUE)
  )

  camino <- TSP::cut_tour(circuito, "corte")
  slice(datos, as.integer(names(camino)))
}

# Interfaz única ####

METODOS <- list(
  "Distancia a cabecera" = ordenar_por_distancia_a_cabecera,
  "Vecino más cercano"   = ordenar_vecino_mas_cercano,
  "PCA"                  = ordenar_pca,
  "TSP"                  = ordenar_tsp
)

ordenar_linea <- function(datos, metodo = "TSP") {
  METODOS[[metodo]](datos)
}

# Aplica todos los métodos a todas las líneas y devuelve un sf largo
# con columnas linea, metodo, orden.
ordenar_red <- function(estaciones, metodos = names(METODOS)) {
  split(estaciones, estaciones$linea) %>%
    map(\(linea) map(metodos, \(m) {
      ordenar_linea(linea, m) %>% mutate(metodo = m, orden = row_number())
    })) %>%
    list_flatten() %>%
    unname() %>%
    do.call(rbind, .)
}
