# Tema y helpers de gráficos ####

library(tidyverse)
library(sf)
library(gganimate)

# Colores de cada línea
COLORES_LINEAS <- c(
  A = "#00AEDA",
  B = "#EE4035",
  C = "#0067B2",
  D = "#008067",
  E = "#6C2180",
  H = "#FFDE00",
  P = "#FBAC23"
)

tema_subte <- function() {
  theme_minimal(base_size = 12) +
    theme(
      panel.grid = element_line(color = "grey92"),
      plot.title = element_text(face = "bold"),
      plot.title.position = "plot",
      legend.position = "none"
    )
}

# Mapa de una línea con las estaciones unidas en el orden en que vienen en `datos`.
# Si el orden es correcto, se ve una línea limpia; si no, aparece el zigzag.
mapa_orden <- function(datos, titulo = NULL, subtitulo = NULL, etiqueta = NULL) {
  coords <- datos %>%
    mutate(
      x = st_coordinates(geometry)[, 1],
      y = st_coordinates(geometry)[, 2],
      orden = row_number()
    ) %>%
    st_drop_geometry()

  color <- COLORES_LINEAS[unique(datos$linea)[1]]
  if (is.na(color)) color <- "grey30"

  p <- ggplot(coords, aes(x, y)) +
    geom_path(color = color, linewidth = 1.2, alpha = 0.8) +
    geom_point(size = 7, shape = 21, fill = "white", color = color, stroke = 1.5) +
    geom_text(aes(label = orden), size = 3, fontface = "bold") +
    coord_equal() +
    labs(title = titulo, subtitle = subtitulo, x = NULL, y = NULL) +
    tema_subte() +
    theme(axis.text = element_blank())

  if (!is.null(etiqueta)) {
    p <- p + ggrepel::geom_text_repel(
      aes(label = .data[[etiqueta]]),
      size = 2.8, color = "grey35", box.padding = 0.6, min.segment.length = 0
    )
  }

  p
}
