# Descarga y limpieza de datos ####
# Cada función cachea en data/ para no volver a bajar en cada render.
# Copia de R/datos.R de github.com/jpcib/subte_estaciones, con rutas relativas
# a la carpeta del post en lugar de here::here() y sin la lectura de molinetes,
# que este post no usa.

library(tidyverse)
library(sf)

URL_ESTACIONES <- "https://cdn.buenosaires.gob.ar/datosabiertos/datasets/sbase/subte-estaciones/estaciones-de-subte.geojson"

# CRS proyectado en metros: POSGAR 2007 / Argentina faja 5
CRS_METROS <- 5347

descargar_si_falta <- function(url, destino) {
  if (!file.exists(destino)) {
    dir.create(dirname(destino), showWarnings = FALSE, recursive = TRUE)
    download.file(url, destino, mode = "wb")
  }
  destino
}

# Estaciones tal cual vienen del dataset (WGS84, sin reproyectar)
leer_estaciones_crudas <- function() {
  archivo <- descargar_si_falta(URL_ESTACIONES, file.path("data", "estaciones.geojson"))

  read_sf(archivo) %>%
    janitor::clean_names()
}

# Estaciones reproyectadas a metros y con nombre normalizado para joins
leer_estaciones <- function() {
  leer_estaciones_crudas() %>%
    st_transform(CRS_METROS) %>%
    mutate(estacion_norm = normalizar_nombre(estacion))
}

# Normaliza nombres de estaciones para poder unir datasets distintos:
# sin tildes, mayúsculas, sin puntuación ni espacios repetidos.
normalizar_nombre <- function(x) {
  x %>%
    stringi::stri_trans_general("Latin-ASCII") %>%
    str_to_upper() %>%
    str_replace_all("[^A-Z0-9 ]", " ") %>%
    str_squish()
}
