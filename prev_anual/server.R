########################################## SERVER ##############################################################

# Logica de un panel de indicadores (series, graficos, tablas, secciones),
# parametrizada por lista de variables -> se reutiliza para "agregados" y
# "desagregados".
panel_indicadores_server <- function(id, variables_lista) {
  moduleServer(id, function(input, output, session) {

    vars_panel <- unname(variables_lista)
    ns <- session$ns

    # --- series sub-anuales (mensual / trimestral) ---
    serie_sub <- function(v, frecuencia, mag) {
      req(input$fuente, input$ajuste)
      lst <- series[[mag]]
      g   <- expand.grid(f = input$fuente, aj = input$ajuste, stringsAsFactors = FALSE)
      claves <- paste(g$f, frecuencia, g$aj, sep = "__")
      claves <- claves[claves %in% names(lst)]
      validate(need(length(claves) > 0, "Selecciona al menos un origen y un ajuste."))

      df <- do.call(rbind, lapply(claves, function(k) {
        d <- lst[[k]]
        data.frame(etiqueta = etq_clave(k), fecha = d$fecha, valor = d[[v]],
                   stringsAsFactors = FALSE)
      }))
      df <- df[!is.na(df$fecha) & df$fecha >= input$rango[1] & df$fecha <= input$rango[2], ]
      validate(need(nrow(df) > 0, "Sin datos en el rango seleccionado."))
      df
    }

    # --- series anuales ---
    serie_anual <- function(v, mag) {
      req(input$fuente, input$ajuste, input$anual_desde, input$rango_anios)
      lst <- series[[mag]]
      g   <- expand.grid(f = input$fuente, fr = input$anual_desde, aj = input$ajuste,
                         stringsAsFactors = FALSE)
      claves <- paste(g$f, g$fr, g$aj, sep = "__")
      claves <- claves[claves %in% names(lst)]
      validate(need(length(claves) > 0, "Selecciona origen, ajuste y frecuencia de partida."))

      df <- do.call(rbind, lapply(claves, function(k) {
        d <- lst[[k]]
        p <- strsplit(k, "__", fixed = TRUE)[[1]]
        full <- periodos_anio[[p[2]]]
        d <- d[d$n_periodos >= full, ]                       # solo anios completos
        if (!nrow(d)) return(NULL)
        data.frame(etiqueta = sprintf("%s · %s · (desde %s)", p[1], p[3], p[2]),
                   anio = d$anio, valor = d[[v]], stringsAsFactors = FALSE)
      }))
      validate(need(!is.null(df) && nrow(df) > 0, "Sin datos anuales en el rango seleccionado."))
      yr <- input$rango_anios
      df <- df[df$anio >= yr[1] & df$anio <= yr[2], ]
      validate(need(nrow(df) > 0, "Sin datos anuales en el rango seleccionado."))
      df
    }

    # --- graficos ---
    # Aplica el estilo AIReF (fondo blanco, rejilla horizontal discontinua,
    # eje negro sin marcas, leyenda horizontal inferior, nota de fuente).
    estilo_airef <- function(p, mag) {
      p %>%
        airef_plotly(leyenda = "bottom", porcentaje = es_tasa(mag)) %>%
        # grafico_sub()/grafico_anual() añaden un rangeslider bajo el eje X;
        # la leyenda por defecto (y = -0.22, margin.b = 60) queda tapada por
        # el rangeslider / fuera del lienzo. Se baja mas y se amplia el margen.
        layout(legend = list(y = -0.4), margin = list(b = 130)) %>%
        airef_fuente_plotly(fuente_datos)
    }

    grafico_sub <- function(v, frecuencia, mag) {
      df <- serie_sub(v, frecuencia, mag)
      p <- plot_ly(df, x = ~fecha, y = ~valor, color = ~etiqueta, colors = airef_pal(),
                   type = "scatter", mode = "lines", line = list(width = 3)) %>%
        layout(
          xaxis = list(
            title = "",
            rangeslider = list(visible = TRUE, thickness = 0.08),
            rangeselector = list(buttons = list(
              list(count = 1,  label = "1a",  step = "year", stepmode = "backward"),
              list(count = 5,  label = "5a",  step = "year", stepmode = "backward"),
              list(count = 10, label = "10a", step = "year", stepmode = "backward"),
              list(step = "all", label = "Todo")
            ))
          ),
          yaxis = list(title = "")
        )
      estilo_airef(p, mag)
    }

    grafico_anual <- function(v, mag) {
      df <- serie_anual(v, mag)
      p <- plot_ly(df, x = ~anio, y = ~valor, color = ~etiqueta, colors = airef_pal(),
                   type = "scatter", mode = "lines", line = list(width = 3)) %>%
        layout(xaxis = list(title = "", dtick = 1, tickformat = "d",
                            rangeslider = list(visible = TRUE, thickness = 0.08)),
               yaxis = list(title = ""))
      estilo_airef(p, mag)
    }

    # --- tablas ---
    tabla_ancha <- function(df, col_indice, mag) {
      ancha <- df %>%
        select(all_of(col_indice), etiqueta, valor) %>%
        pivot_wider(names_from = etiqueta, values_from = valor) %>%
        arrange(.data[[col_indice]])
      names(ancha)[1] <- if (col_indice == "fecha") "Fecha" else "Año"
      if (col_indice == "fecha") ancha$Fecha <- format(ancha$Fecha, "%Y-%m")
      # Estilo AIReF: cabecera granate, Century Gothic, miles con punto y
      # decimales con coma; 1 decimal para tasas, 0 para niveles.
      airef_datatable(ancha, dec = if (es_tasa(mag)) 1 else 0, pageLength = 12)
    }

    tabla_sub   <- function(v, frecuencia, mag) tabla_ancha(serie_sub(v, frecuencia, mag), "fecha", mag)
    tabla_anual <- function(v, mag)             tabla_ancha(serie_anual(v, mag), "anio", mag)

    # --- aviso ---
    output$aviso <- renderUI({
      if (length(proc) == 0)
        div(class = "alert alert-danger",
            "No se ha podido cargar ningún fichero de datos. Revisa las rutas (Z:).")
    })

    # --- secciones (una por variable) ---
    # Los ids de plotlyOutput/DTOutput se generan dinamicamente dentro de un
    # renderUI, por lo que hay que namespaciarlos a mano con ns() para que
    # coincidan con los output[[...]] registrados mas abajo.
    secciones_ui <- function(prefijo) {
      validate(need(length(input$vars) > 0, "Selecciona al menos una serie."))
      tagList(lapply(input$vars, function(v) {
        tagList(
          h3(names(variables_lista)[match(v, variables_lista)]),
          plotlyOutput(ns(paste0("plot_",  prefijo, "_", v)), height = "420px"),
          br(),
          DTOutput(ns(paste0("tabla_", prefijo, "_", v))),
          tags$hr()
        )
      }))
    }
    output$secciones_mensual    <- renderUI(secciones_ui("mensual"))
    output$secciones_trimestral <- renderUI(secciones_ui("trimestral"))
    output$secciones_anual      <- renderUI(secciones_ui("anual"))

    # --- outputs (solo se calculan los de la pestana visible) ---
    for (frecuencia in frecs) {
      for (v in vars_panel) {
        local({
          ff <- frecuencia; vv <- v
          output[[paste0("plot_", ff, "_", vv)]] <- renderPlotly({
            req(vv %in% input$vars, input$freq_tab == ff)
            grafico_sub(vv, ff, input[[paste0("mag_", ff)]])
          })
          output[[paste0("tabla_", ff, "_", vv)]] <- renderDT({
            req(vv %in% input$vars, input$freq_tab == ff)
            tabla_sub(vv, ff, input[[paste0("mag_", ff)]])
          })
        })
      }
    }
    for (v in vars_panel) {
      local({
        vv <- v
        output[[paste0("plot_anual_", vv)]] <- renderPlotly({
          req(vv %in% input$vars, input$freq_tab == "anual")
          grafico_anual(vv, input$mag_anual)
        })
        output[[paste0("tabla_anual_", vv)]] <- renderDT({
          req(vv %in% input$vars, input$freq_tab == "anual")
          tabla_anual(vv, input$mag_anual)
        })
      })
    }
  })
}

server <- function(input, output, session) {
  panel_indicadores_server("agregados", variables)
  panel_indicadores_server("desagregados", variables_desagregados)
}
