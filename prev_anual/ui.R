############################################# UI ###########################################################

# Panel de indicadores (sidebar + graficos/tablas por frecuencia), parametrizado
# por id de modulo y lista de variables -> se reutiliza para "agregados" y
# "desagregados".
panel_indicadores_ui <- function(id, variables_lista, seleccion_inicial) {
  ns <- NS(id)
  sidebarLayout(
    sidebarPanel(
      width = 3,
      checkboxGroupInput(ns("vars"), "series (variables)",
                         choices = variables_lista,
                         selected = seleccion_inicial),
      tags$hr(),
      tags$b("Versión de la serie"),
      helpText("Se puede marcar más de una opción en cada eje."),
      checkboxGroupInput(ns("fuente"), "Origen", choices = fuentes,
                         selected = fuentes, inline = TRUE),
      checkboxGroupInput(ns("ajuste"), "Ajuste", choices = ajustes,
                         selected = "cvec", inline = TRUE),
      tags$hr(),
      conditionalPanel(
        condition = sprintf("input['%s'] != 'anual'", ns("freq_tab")),
        dateRangeInput(ns("rango"), "rango de fechas",
                       start = rango[1], end = rango[2],
                       min = rango[1], max = rango[2],
                       format = "yyyy-mm", startview = "year",
                       weekstart = 1, language = "es", separator = " a ")
      ),
      conditionalPanel(
        condition = sprintf("input['%s'] == 'anual'", ns("freq_tab")),
        sliderInput(ns("rango_anios"), "Años",
                    min = rango_anios[1], max = rango_anios[2],
                    value = rango_anios, step = 1, sep = "")
      )
    ),
    mainPanel(
      width = 9,
      uiOutput(ns("aviso")),
      tabsetPanel(
        id = ns("freq_tab"),

        tabPanel(
          "Mensual", value = "mensual", br(),
          radioButtons(ns("mag_mensual"), "Magnitud", choices = mag_sub("mensual"), inline = TRUE),
          uiOutput(ns("secciones_mensual"))
        ),

        tabPanel(
          "Trimestral", value = "trimestral", br(),
          radioButtons(ns("mag_trimestral"), "Magnitud", choices = mag_sub("trimestral"), inline = TRUE),
          uiOutput(ns("secciones_trimestral"))
        ),

        tabPanel(
          "Anual", value = "anual", br(),
          fluidRow(
            column(6, radioButtons(ns("mag_anual"), "Magnitud", choices = mag_anual, inline = TRUE)),
            column(6, checkboxGroupInput(ns("anual_desde"), "Calculado a partir de",
                                         choices = frecs, selected = frecs, inline = TRUE))
          ),
          helpText("El nivel anual es el promedio de los meses / trimestres del año. ",
                   "Solo se muestran años completos."),
          uiOutput(ns("secciones_anual"))
        )
      )
    )
  )
}

ui <- navbarPage(
  title = "Indicadores Seguridad Social",

  header = tags$head(tags$style(HTML("
    body, .navbar, .form-control, .btn, label {
      font-family: 'Gill Sans MT','Gill Sans','Trebuchet MS','Segoe UI',sans-serif;
    }
    .navbar-default {
      background-color: #83082A; border-color: #430416;
    }
    .navbar-default .navbar-brand,
    .navbar-default .navbar-nav > li > a { color: #fff; }
    .navbar-default .navbar-brand:hover,
    .navbar-default .navbar-nav > li > a:hover,
    .navbar-default .navbar-nav > .active > a,
    .navbar-default .navbar-nav > .active > a:hover,
    .navbar-default .navbar-nav > .active > a:focus {
      color: #fff; background-color: #430416;
    }
    h3, h4 { color: #83082A; font-weight: 700; text-transform: uppercase; }
    .nav-tabs > li.active > a,
    .nav-tabs > li.active > a:hover { color: #83082A; font-weight: 700; }
    a { color: #83082A; }
    .irs-bar, .irs-bar-edge, .irs-single, .irs-from, .irs-to {
      background: #83082A; border-color: #83082A;
    }
    input[type=checkbox], input[type=radio] { accent-color: #83082A; }
  "))),

  tabPanel(
    "Indicadores desagregados",
    panel_indicadores_ui("desagregados", variables_desagregados,
                         seleccion_inicial = unname(variables_desagregados)[1:2])
  ),

  tabPanel(
    "Indicadores agregados",
    panel_indicadores_ui("agregados", variables,
                         seleccion_inicial = c("Cotizaciones_cn", "Cotizaciones_componentes"))
  )
)
