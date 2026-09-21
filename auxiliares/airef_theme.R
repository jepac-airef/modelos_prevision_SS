############################################################################
#  airef_theme.R  --  Estilo visual AIReF (tema "AIReF 2026")
#  Gráficos: plotly / ggplot2   |   Tablas: DT / gt
#
#  Uso:  source("~/.claude/skills/airef-formato/assets/airef_theme.R")
#        (o copiar este fichero al proyecto si Z:/rutas de red no están
#         disponibles en el servidor de despliegue)
############################################################################

# --- Paleta -------------------------------------------------------------------

airef_colores <- c(
  granate        = "#83082A",  # accent1 - serie destacada, títulos, cabeceras
  granate_oscuro = "#430416",  # accent2
  granate_medio  = "#8C2633",  # accent3
  carmin         = "#D00D43",  # accent4 - alertas puntuales
  rosa           = "#D46271",  # accent5
  rosa_claro     = "#E397A0",  # accent6 - series secundarias, bandas
  negro          = "#000000",  # ejes, texto, línea de "Total/General"
  gris_oscuro    = "#404040",
  gris_medio     = "#595959",
  gris_rejilla   = "#D9D9D9",
  gris_panel     = "#E7E6E6",  # lt2 - series de fondo
  ambar          = "#FFC000",  # contraste: UNA serie a resaltar
  azul           = "#548CC6",  # contraste: serie ajena al bloque granate
  azul_gris      = "#44546A",  # dk2
  banda_inc      = "#F3D1D5"   # relleno de bandas de incertidumbre
)

# Secuencia categórica (orden de asignación a series)
airef_secuencia <- c("#83082A", "#E397A0", "#8C2633", "#D46271",
                     "#430416", "#595959", "#D9D9D9")

#' n colores de la secuencia categórica AIReF (recicla si n > 7)
airef_pal <- function(n = 7) {
  if (n <= length(airef_secuencia)) airef_secuencia[seq_len(n)]
  else rep(airef_secuencia, length.out = n)
}

#' Rampa secuencial AIReF (claro -> granate oscuro), para heatmaps / mapas
airef_pal_secuencial <- function(n = 9) {
  grDevices::colorRampPalette(c("#F4D8DB", "#83082A", "#430416"))(n)
}

# --- Tipografía --------------------------------------------------------------

airef_font_grafico <- "Gill Sans MT, Gill Sans, 'Trebuchet MS', 'Segoe UI', sans-serif"
airef_font_tabla   <- "Century Gothic, 'Apple Gothic', 'Trebuchet MS', sans-serif"

# ===========================================================================
#  ggplot2
# ===========================================================================

#' Tema ggplot2 AIReF: rejilla horizontal discontinua, sin borde, fondo blanco
theme_airef <- function(base_size = 11, base_family = "") {
  ggplot2::`%+replace%`(
    ggplot2::theme_minimal(base_size = base_size, base_family = base_family),
    ggplot2::theme(
      plot.background   = ggplot2::element_rect(fill = "white", colour = NA),
      panel.background  = ggplot2::element_rect(fill = "white", colour = NA),
      panel.grid.major.y = ggplot2::element_line(colour = "#D9D9D9", linetype = "dashed", linewidth = 0.3),
      panel.grid.major.x = ggplot2::element_blank(),
      panel.grid.minor   = ggplot2::element_blank(),
      axis.line.x        = ggplot2::element_line(colour = "black", linewidth = 0.3),
      axis.ticks         = ggplot2::element_blank(),
      axis.text          = ggplot2::element_text(colour = "black", size = ggplot2::rel(0.85)),
      axis.title         = ggplot2::element_text(colour = "#404040", size = ggplot2::rel(0.9)),
      legend.position    = "top",
      legend.title       = ggplot2::element_blank(),
      legend.text        = ggplot2::element_text(colour = "#595959", size = ggplot2::rel(0.9)),
      plot.title         = ggplot2::element_text(colour = "#83082A", face = "bold",
                                                 size = ggplot2::rel(1.15), hjust = 0),
      plot.title.position = "plot",
      plot.caption       = ggplot2::element_text(colour = "#595959", face = "italic",
                                                 size = ggplot2::rel(0.8), hjust = 0),
      plot.caption.position = "plot"
    )
  )
}

scale_color_airef <- function(...) ggplot2::discrete_scale("colour", "airef", airef_pal, ...)
scale_fill_airef  <- function(...) ggplot2::discrete_scale("fill",   "airef", airef_pal, ...)
scale_colour_airef <- scale_color_airef

#' Título/subtítulo/fuente al estilo AIReF para ggplot2
#'   labs(title = airef_titulo(1, "EVOLUCIÓN DEL SALDO", "% PIB"), caption = "Fuente: AIReF")
airef_titulo <- function(n, titulo, unidad = NULL) {
  t <- sprintf("GRÁFICO %s. %s", n, toupper(titulo))
  if (!is.null(unidad)) t <- sprintf("%s (%s)", t, unidad)
  t
}

# ===========================================================================
#  plotly
# ===========================================================================

#' Aplica el layout AIReF a un objeto plotly.
#' @param p objeto plotly
#' @param leyenda "top", "bottom" o "none"
#' @param porcentaje si TRUE, sufijo % en el eje Y
airef_plotly <- function(p, leyenda = "bottom", porcentaje = FALSE) {
  eje_x <- list(
    title = "", showgrid = FALSE, zeroline = FALSE,
    linecolor = "black", linewidth = 1, ticks = "", automargin = TRUE
  )
  eje_y <- list(
    title = "", zeroline = FALSE, showline = FALSE, ticks = "",
    gridcolor = "#D9D9D9", griddash = "dash", gridwidth = 1,
    automargin = TRUE
  )
  if (porcentaje) eje_y$ticksuffix <- "%"

  leg <- switch(leyenda,
    top    = list(orientation = "h", x = 0, y = 1.12, xanchor = "left"),
    bottom = list(orientation = "h", x = 0, y = -0.22, xanchor = "left"),
    none   = NULL
  )

  p <- plotly::layout(
    p,
    paper_bgcolor = "white", plot_bgcolor = "white",
    font = list(family = airef_font_grafico, size = 13, color = "black"),
    xaxis = eje_x, yaxis = eje_y,
    showlegend = !identical(leyenda, "none"),
    legend = c(leg, list(font = list(color = "#595959", size = 12),
                         bgcolor = "rgba(0,0,0,0)")),
    hovermode = "x unified",
    margin = list(l = 60, r = 20, t = 30, b = 60)
  )
  # colorway: se usa cuando las trazas no fijan color explícito
  p <- plotly::layout(p, colorway = airef_secuencia)
  p
}

#' Traza de línea AIReF (sin marcadores, 2,25 pt). Añádela con add_trace()/add_lines().
airef_linea <- function(color = "#83082A", dash = "solid") {
  list(color = color, width = 3, dash = dash)
}

#' Anotación de fuente bajo el gráfico
airef_fuente_plotly <- function(p, texto = "Fuente: AIReF") {
  plotly::layout(p, annotations = list(list(
    text = texto, showarrow = FALSE,
    xref = "paper", yref = "paper", x = 0, y = -0.35,
    xanchor = "left", yanchor = "top",
    font = list(family = airef_font_grafico, size = 11,
                color = "#595959", style = "italic")
  )))
}

# ===========================================================================
#  DT::datatable
# ===========================================================================

#' datatable con estilo AIReF (cabecera granate, Century Gothic, números a la derecha)
#' @param df data.frame
#' @param dec decimales para columnas numéricas
#' @param pct columnas (nombres) a formatear como porcentaje
#' @param ... se pasa a DT::datatable
airef_datatable <- function(df, dec = 1, pct = character(), ..., pageLength = 12) {
  num_cols <- names(df)[vapply(df, is.numeric, logical(1))]
  css <- "
    table.dataTable, table.dataTable td, table.dataTable th {
      font-family: Century Gothic, 'Apple Gothic', 'Trebuchet MS', sans-serif;
      font-size: 13px;
    }
    table.dataTable thead th {
      background-color: #83082A; color: #fff; font-weight: 700;
      border-bottom: 2px solid #83082A;
    }
    table.dataTable tbody tr.total td { background-color: #E7E6E6; font-weight: 700; }
    table.dataTable.stripe tbody tr.odd { background-color: #F7F2F3; }
  "
  dots <- list(...)
  extra_opts <- dots$options %||% list()
  dots$options <- NULL          # se fusiona en `options`, no se re-pasa a datatable
  dt <- do.call(DT::datatable, c(
    list(df, rownames = FALSE,
         options = utils::modifyList(
           list(pageLength = pageLength, scrollX = TRUE, dom = "tip",
                columnDefs = list(list(className = "dt-right",
                                       targets = which(names(df) %in% num_cols) - 1))),
           extra_opts)),
    dots
  ))
  dt$dependencies <- c(dt$dependencies,
                       list(htmltools::htmlDependency(
                         "airef-dt", "1.0", src = c(href = ""),
                         head = sprintf("<style>%s</style>", css))))
  plain <- setdiff(num_cols, pct)
  if (length(plain)) dt <- DT::formatRound(dt, plain, digits = dec,
                                           mark = ".", dec.mark = ",")
  if (length(pct))   dt <- DT::formatPercentage(dt, pct, digits = dec,
                                                mark = ".", dec.mark = ",")
  dt
}

`%||%` <- function(a, b) if (is.null(a)) b else a

# ===========================================================================
#  gt
# ===========================================================================

#' Estilo AIReF para una tabla gt
airef_gt <- function(gt_tbl, fuente = "Fuente: AIReF") {
  gt_tbl |>
    gt::opt_table_font(font = list(gt::google_font("Questrial"), "Century Gothic", "sans-serif")) |>
    gt::tab_options(
      table.font.size = gt::px(13),
      column_labels.background.color = "#83082A",
      column_labels.font.weight = "bold",
      table.border.top.style = "none",
      table_body.border.bottom.color = "#83082A",
      table_body.hlines.style = "none",
      heading.title.font.weight = "bold",
      source_notes.font.size = gt::px(11)
    ) |>
    gt::tab_style(
      style = gt::cell_text(color = "white"),
      locations = gt::cells_column_labels()
    ) |>
    gt::tab_style(
      style = gt::cell_text(color = "#83082A", weight = "bold"),
      locations = gt::cells_title(groups = "title")
    ) |>
    gt::tab_source_note(gt::md(sprintf("*%s*", fuente)))
}

# ===========================================================================
#  Formato numérico (locale español)
# ===========================================================================

#' Formatea al estilo español: miles con punto, decimales con coma
airef_num <- function(x, dec = 1, pct = FALSE) {
  if (pct) x <- x * 100
  out <- formatC(x, format = "f", digits = dec, big.mark = ".", decimal.mark = ",")
  out[is.na(x)] <- "n.d."
  if (pct) out <- paste0(out, "%")
  out
}

# ===========================================================================
#  EJEMPLOS
# ===========================================================================
if (FALSE) {

  ## ---- ggplot2 --------------------------------------------------------------
  library(ggplot2)
  ggplot(economics_long, aes(date, value01, colour = variable)) +
    geom_line(linewidth = 0.9) +
    scale_colour_airef() +
    theme_airef() +
    labs(title = airef_titulo(1, "Indicadores económicos", "índice"),
         caption = "Fuente: AIReF")

  ## ---- plotly (como en app.R) --------------------------------------------
  library(plotly)
  p <- plot_ly(df, x = ~fecha, y = ~valor, color = ~etiqueta,
               type = "scatter", mode = "lines",
               line = list(width = 3)) |>
    airef_plotly(leyenda = "bottom", porcentaje = TRUE) |>
    airef_fuente_plotly("Fuente: IGAE y AIReF")

  ## Resaltar una sola serie: color explícito granate + resto gris
  plot_ly(df, x = ~fecha, y = ~valor, split = ~etiqueta,
          type = "scatter", mode = "lines",
          color = ~I(ifelse(etiqueta == "España", "#83082A", "#D9D9D9"))) |>
    airef_plotly()

  ## ---- DT (como en app.R) ----------------------------------------------
  airef_datatable(tabla_ancha, dec = 2, pct = c("Tasa interanual"))

  ## ---- gt -----------------------------------------------------------------
  gt::gt(head(mtcars)) |> airef_gt(fuente = "Fuente: AIReF")
}
