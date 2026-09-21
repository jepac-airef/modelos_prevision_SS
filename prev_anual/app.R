############################################################################################################################
########################################## APP COMPARACIÓN INDICADORES DE SS ###############################################
############################################################################################################################

# 0. Rutas y directorios

rm(list=ls()) 
fileloc <- dirname(rstudioapi::getSourceEditorContext()$path) 
setwd(fileloc) 
librerias <- c("shiny", "readxl", "ggplot2", "gridExtra", "plotly", "dygraphs",
               "numDeriv", "MASS", "maxLik", "miscTools", "xts", "openxlsx",
               "DT", "dplyr", "tidyr")


faltantes <- librerias[!sapply(librerias, requireNamespace, quietly = TRUE)]
if (length(faltantes) > 0) install.packages(faltantes)

invisible(lapply(librerias, library, character.only = TRUE))


# 1. Carga de varips

source("airef_theme.R")
source("funcionalidades.R")
source("funciones_aux.R")
source("ui.R")
source("server.R")

# 2. App

shinyApp(ui, server)
