# Modelos de previsión de la Seguridad Social

Repositorio para la gestión de análisis, procesos reproducibles y comparaciones de modelos de previsión de indicadores de la Seguridad Social.

## Objetivo

Este repositorio está organizado por carpetas temáticas y por proceso analítico. La idea es separar:

- utilidades y funciones reutilizables comunes a varios proyectos,
- cada análisis o flujo específico de modelización,
- y los artefactos asociados a cada proceso.

## Estructura del repositorio

```text
modelos_prevision_SS/
├── auxiliares/                 # Funciones y utilidades compartidas
│   └── airef_theme.R           # Estilo y formato corporativo AIREF
├── prev_anual_ARIMAs/          # Proyecto de previsión anual / ARIMAs
│   ├── app.R
│   ├── server.R
│   ├── ui.R
│   ├── funcionalidades.R
│   ├── funciones_aux.R
│   └── ...
├── modelos_previsión_SS/       # Carpeta reservada para otros modelos/procesos
│   └── ...
├── README.md
├── .gitignore
└── ...
```

## Carpetas principales

### auxiliares/

Carpeta de funciones y utilidades compartidas por todos los proyectos del repositorio. Aquí se almacenan:

- helpers generales,
- funciones de formato, temas y estilo,
- utilidades de visualización,
- funciones reutilizables para distintos análisis.

En este momento, incluye elementos orientados a formato y visualización corporativa de AIREF, por ejemplo:

- `airef_theme.R`

La finalidad es evitar duplicar lógica entre distintos análisis y mantener un punto único de configuración visual y auxiliar.

### prev_anual_ARIMAs/

Carpeta correspondiente al análisis o proceso reproducible de previsión anual. En ella se guardan los scripts y artefactos específicos del flujo de trabajo asociado a ese modelo o aplicación.

Incluye, entre otros elementos:

- interfaz de la aplicación,
- lógica del servidor,
- funciones específicas del análisis,
- resultados y outputs del proceso.


