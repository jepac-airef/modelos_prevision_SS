##################################################################################################################
######################################### FUNCIONALIDADES PARA APP DE INDICADORES SS #############################
##################################################################################################################

# 0. Rutas a datos

rutas <- c(
  new = "Z:\\AIREF\\Comun\\Desestacionalizacion\\02_Datos\\Seguridad_Social\\SA_analisis",
  old = "Z:\\AIREF\\Comun\\Desestacionalizacion\\02_Datos\\Seguridad_Social"
)

fuente_datos <- "Fuente: Seguridad Social y AIReF"

# 1. Versiones de los datos

fuentes<- c("old", "new")
ajustes<- c("raw", "cvec")
frecs<- c("mensual", "trimestral")
periodos_anio<- c(mensual = 12L, trimestral = 4L)

# 2. Variables agregadas -> etiqueta legible = nombre del elemento

variables <- c(
  "Cotizaciones (CN)"               = "Cotizaciones_cn",
  "Cotizaciones (componentes)"      = "Cotizaciones_componentes",
  "Desempleo (compuesto)"           = "Desempleo_compuesto",
  "Desempleo (cont + no cont)"      = "Desempleo_cont_nocont_1",
  "Desempleo (estim. directa)"      = "Desempleo_estim_directa_1",
  "Desempleo est. (cont + no cont)" = "Desempleo_cont_nocont_2",
  "Desempleo est. (estim. directa)" = "Desempleo_estim_directa_2"
)

# 2b. Variables desagregadas (componentes individuales, sin sumar)

variables_desagregados <- c(
  "Cotiz. Régimen General"          = "Cotiz_RG",
  "Cotiz. RETA"                          = "Cotiz_RETA",
  "Cotiz. SEPE"                          = "Cotiz_SEPE",
  "Cotiz. ATyEP"                         = "Cotiz_ATyEP",
  "Cotiz. desempleados"                  = "Cotiz_desempleados",
  "Beneficiarios prest. contributiva"    = "Ben_prest_cont",
  "Prestación media contributiva"   = "Prest_media_cont",
  "Beneficiarios prest. no contributiva" = "Ben_prest_no_cont",
  "Prestación media no contributiva"= "Prest_media_no_cont",
  "Desempleo contributivo"               = "Des_Cont",
  "Desempleo no contributivo"            = "Des_No_Cont",
  "Desempleo contributivo (est.)"        = "Des_Cont_est",
  "Desempleo no contributivo (est.)"     = "Des_No_Cont_est"
)

# 3. Magnitudes y unidad de cuenta de los datos

mag_sub <- function(frecuencia) c("Nivel"= "nivel",
  setNames("tasa_periodo",
           if (frecuencia == "mensual") "Tasa intermensual" else "Tasa intertrimestral"), 
  "Tasa interanual"= "tasa_interanual")

mag_anual <- c("Nivel (promedio anual)" = "anual_nivel", "Tasa interanual" = "anual_tasa")

# 4. Elegir hoja de excel a cargar

hoja_de <- function(frecuencia, ajuste) {
  fr <- c(mensual = "mensuales", trimestral = "trimestrales")[[frecuencia]]
  aj <- c(raw = "Raw", cvec = "CVEC")[[ajuste]]
  sprintf("Ind. %s (%s)", fr, aj)
}

# 5. Transformación para filtrar fechas

periodo_a_fecha <- function(periodo, frecuencia) {
  p    <- strsplit(trimws(periodo), "\\s+")
  anio <- as.integer(vapply(p, `[`, "", 1))
  num  <- as.integer(vapply(p, `[`, "", 2))
  mes  <- if (frecuencia == "trimestral") (num - 1L) * 3L + 1L else num
  as.Date(sprintf("%d-%02d-01", anio, mes))
}