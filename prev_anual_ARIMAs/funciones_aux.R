###################################################################################################################
####################################### FUNCIONES TRANSFORMACIÓN Y PRESENTACIÓN DE DATOS ##########################
###################################################################################################################

# 1. Transformacion base

agregar_version <- function(df, frecuencia) {
  names(df)[1] <- "periodo"
  names(df)    <- sub("_[Qq]$", "", names(df))   # trimestrales: Cotiz_RG_Q -> Cotiz_RG
  
  out <- data.frame(
    fecha = periodo_a_fecha(df$periodo, frecuencia),
    
    Cotizaciones_cn = df$Cotiz_CN,
    
    Cotizaciones_componentes = df$Cotiz_RG + df$Cotiz_RETA + df$Cotiz_SEPE +
      df$Cotiz_desempleados + df$Cotiz_ATyEP,

    Desempleo_compuesto = df$Ben_prest_cont * df$Prest_media_cont +
      df$Ben_prest_no_cont * df$Prest_media_no_cont,

    Desempleo_cont_nocont_1   = df$Des_Cont + df$Des_No_Cont,
    Desempleo_estim_directa_1 = df$Desempleo,
    Desempleo_cont_nocont_2   = df$Des_Cont_est + df$Des_No_Cont_est,
    Desempleo_estim_directa_2 = df$Desempleo_est,

    # -- componentes individuales (indicadores desagregados) --
    Cotiz_RG            = df$Cotiz_RG,
    Cotiz_RETA          = df$Cotiz_RETA,
    Cotiz_SEPE          = df$Cotiz_SEPE,
    Cotiz_ATyEP         = df$Cotiz_ATyEP,
    Cotiz_desempleados  = df$Cotiz_desempleados,
    Ben_prest_cont      = df$Ben_prest_cont,
    Prest_media_cont    = df$Prest_media_cont,
    Ben_prest_no_cont   = df$Ben_prest_no_cont,
    Prest_media_no_cont = df$Prest_media_no_cont,
    Des_Cont            = df$Des_Cont,
    Des_No_Cont         = df$Des_No_Cont,
    Des_Cont_est        = df$Des_Cont_est,
    Des_No_Cont_est     = df$Des_No_Cont_est,

    stringsAsFactors = FALSE
  )
  out[!is.na(out$fecha), , drop = FALSE]
}

# 2. Transformación datos

lag_vec <- function(x, k = 1L) if (k >= length(x)) rep(NA_real_, length(x)) else c(rep(NA_real_, k), head(x, -k))
tasa    <- function(x, k = 1L) 100 * (x / lag_vec(x, k) - 1)
media_sin_na <- function(x) { m <- mean(x, na.rm = TRUE); if (is.nan(m)) NA_real_ else m }

vars <- unname(c(variables, variables_desagregados))

procesar_version <- function(d, frecuencia) {
  d <- d[order(d$fecha), , drop = FALSE]
  m <- periodos_anio[[frecuencia]]
  
  t_periodo <- t_interanual <- d
  t_periodo[vars]    <- lapply(d[vars], tasa, k = 1L)
  t_interanual[vars] <- lapply(d[vars], tasa, k = m)
  
  anio <- as.integer(format(d$fecha, "%Y"))
  an   <- aggregate(d[vars], by = list(anio = anio), FUN = media_sin_na)
  an$n_periodos <- as.integer(table(factor(anio, levels = an$anio)))
  an$fecha <- as.Date(sprintf("%d-01-01", an$anio))
  
  at <- an[c("anio", "n_periodos", "fecha")]
  at[vars] <- lapply(an[vars], tasa, k = 1L)
  
  list(nivel = d, tasa_periodo = t_periodo, tasa_interanual = t_interanual,
       anual_nivel = an, anual_tasa = at)
}

# 3. Cargar y procesar datos

cargar_todo <- function() {
  proc <- list()
  for (f in fuentes) for (fr in frecs) for (aj in ajustes) {
    archivo <- file.path(rutas[[f]], "MOD_I_resultados.xlsx")
    crudo   <- tryCatch(
      suppressMessages(read_excel(archivo, sheet = hoja_de(fr, aj))),
      error = function(e) { warning(sprintf("No se pudo leer %s [%s]: %s", archivo, hoja_de(fr, aj), conditionMessage(e))); NULL }
    )
    if (is.null(crudo)) next
    proc[[paste(f, fr, aj, sep = "__")]] <- procesar_version(agregar_version(crudo, fr), fr)
  }
  proc
}

proc <- cargar_todo()

# 4. Listas por magnitud, cada una con las 8 versiones 

series <- list(
  nivel           = lapply(proc, `[[`, "nivel"),
  tasa_periodo    = lapply(proc, `[[`, "tasa_periodo"),
  tasa_interanual = lapply(proc, `[[`, "tasa_interanual"),
  anual_nivel     = lapply(proc, `[[`, "anual_nivel"),
  anual_tasa      = lapply(proc, `[[`, "anual_tasa")
)

rango <- if (length(proc))
  range(do.call(c, lapply(series$nivel, `[[`, "fecha")), na.rm = TRUE) else
    c(Sys.Date() - 3650, Sys.Date())

rango_anios <- as.integer(format(rango, "%Y"))

es_tasa   <- function(mag) grepl("tasa", mag)
etq_clave <- function(k) { p <- strsplit(k, "__", fixed = TRUE)[[1]]; paste(p[1], p[3], sep = " \u00b7 ") }