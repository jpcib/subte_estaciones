# Plan de commits: publicar «Cómo complicar un problema sencillo»

Carpeta a publicar: `publicar/2026-11-25-sobrepensar-el-subte/` (index.qmd + R/).
Sigue `portfolio-site/arquitectura-sitio.md`: el laboratorio (`subte_estaciones`) se
etiqueta, el post se copia al repo `blog` y `portfolio-site` queda solo como portada.

Orden: **laboratorio → blog → portada**. Cada bloque depende del anterior.

## Antes de empezar

- [ ] `index.qmd`, línea ~567: hay una `r` suelta donde estaba
      `<!-- TODO: link al post de TSP cuando esté publicado. -->`. Se renderiza como un
      párrafo con la letra «r». Corregirla en `publicar/…/index.qmd`.
- [ ] Fecha: el front matter dice `date: 2026-10-08` y la carpeta `2026-11-25`. Elegir una
      y alinear las dos (el listado del blog ordena por `date`).
- [ ] Listado `type: grid`: agregar `image:` al front matter (p. ej. el mapa de la red
      ordenada). Si no, Quarto usa la primera imagen que encuentra.

---

## 1. `subte_estaciones` (laboratorio)

Estado actual: `.gitignore` y `distancias_estaciones.R` modificados; `R/`, `README.md`,
`_quarto.yml`, `posts/`, `_freeze/` y `publicar/` sin versionar.

| # | Archivos | Mensaje |
|---|---|---|
| L1 | `.gitignore` | `chore: ignorar salidas de Quarto` |
| L2 | `R/datos.R`, `R/graficos.R`, `R/ordenar.R` | `feat: helpers de datos, gráficos y ordenamiento` |
| L3 | `_quarto.yml`, `posts/es/index.qmd` | `feat: post 1, cómo complicar un problema sencillo` |
| L4 | `posts/tsp/index.qmd`, `posts/moran/index.qmd` | `docs: borradores de los posts 2 (TSP) y 3 (Moran)` |
| L5 | `README.md` | `docs: README de la serie` |
| L6 | `distancias_estaciones.R` | `chore: exploración de la red y la línea H` |
| L7 | `publicar/2026-11-25-sobrepensar-el-subte/`, este plan | `feat: versión del post 1 adaptada para el blog` |

Notas:
- **L1**: decidir si el laboratorio versiona `posts/es/index.html` y `_freeze/`. Propuesta:
  no hacerlo (el render publicable vive en `blog`); sumar al `.gitignore` antes de L1:
  ```
  posts/**/*.html
  _freeze/
  ```
- **L6**: el diff descomenta `install.packages("sfdep")` en la línea 4, así que se
  reinstala el paquete cada vez que se corre el script. Volver a comentarlo antes de commitear.
- **Tag** sobre L7 (marca el origen exacto de lo publicado):
  ```bash
  git tag -a blog/2026-11-25-sobrepensar-el-subte -m "Publicado en blog.juancib.ar"
  git push origin main --follow-tags
  ```

## 2. `blog` (repo nuevo)

Se crea una vez (`git init`, repo `jpcib/blog` en GitHub, alta del subdominio según
«Alta de un subdominio» en la arquitectura).

| # | Archivos | Mensaje |
|---|---|---|
| B1 | `_quarto.yml`, `index.qmd`, `CNAME`, `.gitignore` | `chore: estructura del blog` |
| B2 | `posts/2026-11-25-sobrepensar-el-subte/` (qmd + R/), `_freeze/` | `post: cómo complicar un problema sencillo` |

Notas:
- **B1**, contenido mínimo:
  - `_quarto.yml`: `type: website`, `site-url: https://blog.juancib.ar`,
    `resources: [CNAME]`, `execute: freeze: auto`, navbar con links absolutos
    (`https://juancib.ar`, `https://cv.juancib.ar`).
  - `index.qmd`: `listing: { contents: posts, type: grid, sort: "date desc", categories: true }`.
  - `CNAME`: `blog.juancib.ar`.
  - `.gitignore`: `/.quarto/`, `/_site/`, `posts/*/data/`, `**/*.quarto_ipynb`.
- **B2**: copiar el contenido de `publicar/2026-11-25-sobrepensar-el-subte/` a
  `posts/2026-11-25-sobrepensar-el-subte/`, renderizar y recién después commitear,
  incluyendo `_freeze/`. En el cuerpo del commit:
  `Origen: jpcib/subte_estaciones@blog/2026-11-25-sobrepensar-el-subte`.
- **Tag y publicación**:
  ```bash
  git tag -a sobrepensar-el-subte -m "Post 1 de SobrePensar"
  git push origin main --follow-tags
  quarto publish gh-pages
  ```

## 3. `portfolio-site` (portada)

| # | Archivos | Mensaje |
|---|---|---|
| P0 | `proyectos/posts/sobrepensar-el-subte/` | *(sin commit: está sin versionar, se borra la carpeta)* |
| P1 | `arquitectura-sitio.md` | `docs: arquitectura del sitio por subdominios` |
| P2 | `.gitignore` | `chore: quitar regla de datos de posts (pasa al blog)` |
| P3 | `_quarto.yml` | `feat: link al blog en la navbar` |

Notas:
- **P0**: la copia del post en la portada queda reemplazada por la versión en `publicar/`
  (es la misma, más la categoría `SobrePensar`).
- **P2**: revierte la línea `proyectos/posts/*/data/` que agregó 6de7aac. `freeze: auto`
  puede quedarse: no molesta y sirve si la portada alguna vez ejecuta código.
- **P3**: recién cuando `blog.juancib.ar` responda con HTTPS. Reemplazar o complementar
  «Proyectos» con `https://blog.juancib.ar`. Los posts `ejemplo-1` y `ejemplo-2` se
  pueden borrar en el mismo commit si la sección desaparece.
