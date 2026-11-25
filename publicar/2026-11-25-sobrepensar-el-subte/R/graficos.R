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

# Sistema de diseño juancib.ar (tema Papel) ####
# Los gráficos son láminas sobre papel: fondo placa, grilla en línea, texto en tinta.
ATLAS <- c(
  placa       = "#FBFAF7",
  tinta       = "#1E2430",
  tinta_media = "#475063",
  tinta_suave = "#626A7A",
  linea       = "#D8D3C7",
  frontera    = "#A8433A"
)
PAISES      <- c("#F2C6BA", "#F2E3A6", "#CADDB4", "#D8CBE5", "#F4D3AB")
BATIMETRIA  <- c("#D3E6EC", "#B4CFDB", "#8FB4C6", "#5E8FA9", "#356F8E")
HIPSOMETRIA <- c("#B9D3A2", "#E2E1A6", "#E8CB94", "#CFA77E", "#A57E5E")

# Usa la fuente si está instalada; si no, la genérica (el render no falla)
fuente <- function(familia, alternativa) {
  instaladas <- tryCatch(systemfonts::system_fonts()$family, error = function(e) character())
  if (familia %in% instaladas) familia else alternativa
}

tema_atlas <- function(base_size = 12) {
  texto  <- fuente("Source Serif 4", "serif")
  titulo <- fuente("Archivo", "sans")
  rotulo <- fuente("Archivo Narrow", "sans")

  theme_minimal(base_size = base_size, base_family = texto) +
    theme(
      plot.background     = element_rect(fill = ATLAS[["placa"]], colour = NA),
      panel.grid          = element_line(colour = ATLAS[["linea"]], linewidth = 0.3),
      text                = element_text(colour = ATLAS[["tinta"]]),
      axis.text           = element_text(colour = ATLAS[["tinta_media"]], family = rotulo),
      legend.title        = element_text(family = rotulo, colour = ATLAS[["tinta_media"]]),
      plot.title          = element_text(family = titulo, face = "bold"),
      plot.subtitle       = element_text(face = "italic", colour = ATLAS[["tinta_media"]]),
      plot.caption        = element_text(family = rotulo, colour = ATLAS[["tinta_suave"]]),
      plot.title.position = "plot"
    )
}

# Tema de la serie: el del atlas, sin leyenda (las líneas se rotulan directo)
tema_subte <- function() {
  tema_atlas() +
    theme(legend.position = "none")
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
  if (is.na(color)) color <- ATLAS[["tinta_media"]]

  p <- ggplot(coords, aes(x, y)) +
    geom_path(color = color, linewidth = 1.2, alpha = 0.8) +
    geom_point(size = 7, shape = 21, fill = ATLAS[["placa"]], color = color, stroke = 1.5) +
    geom_text(aes(label = orden), size = 3, fontface = "bold", colour = ATLAS[["tinta"]]) +
    coord_equal() +
    labs(title = titulo, subtitle = subtitulo, x = NULL, y = NULL) +
    tema_subte() +
    theme(axis.text = element_blank())

  if (!is.null(etiqueta)) {
    p <- p + ggrepel::geom_text_repel(
      aes(label = .data[[etiqueta]]),
      size = 2.8, color = ATLAS[["tinta_media"]], box.padding = 0.6, min.segment.length = 0
    )
  }

  p
}
