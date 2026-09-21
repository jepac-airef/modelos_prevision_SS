---
name: airef-formato
description: >-
  Estilo visual de la AIReF (tema "AIReF 2026") para gráficos y tablas/cuadros en
  cualquier app o informe: paleta granate corporativa, tipografías, rejilla, notas
  de fuente y formato numérico en español. Usar al crear o revisar gráficos
  (plotly, ggplot2, highcharter) o tablas (DT, gt, reactable, flextable, kableExtra)
  en R/Shiny, R Markdown, Quarto o exportaciones a Excel/Office.
---

# Formato AIReF — gráficos y cuadros

Aplica la identidad visual de la AIReF a cualquier salida gráfica o tabular. Deriva
de `Tema AIReF 2026.thmx` y `Plantilla Graficos y cuadros.xlsx`
(`Z:\AIREF\01. Gráficos Informes\`).

## Cómo usar este skill

1. Carga los helpers: `source("~/.claude/skills/airef-formato/assets/airef_theme.R")`
   (o copia el fichero al proyecto si `Z:` / rutas de red no están disponibles en despliegue).
2. Envuelve cada gráfico y cada tabla con la función AIReF correspondiente (ver abajo).
3. Respeta las reglas de rejilla, leyenda, título y fuente aunque no uses los helpers.

Si el proyecto ya tiene su propio fichero de tema, **no** lo dupliques: alinéalo con
la paleta y las reglas de esta ficha.

## Paleta (tema AIReF 2026)

| Rol | Hex | Uso |
|---|---|---|
| Granate principal (`accent1`) | `#83082A` | serie destacada, títulos, barras principales |
| Granate oscuro (`accent2`)    | `#430416` | 5.º color de serie, énfasis fuerte |
| Granate medio (`accent3`)     | `#8C2633` | 2.ª/3.ª serie |
| Carmín (`accent4`)            | `#D00D43` | alertas puntuales, no como color base |
| Rosa (`accent5`)              | `#D46271` | serie secundaria |
| Rosa claro (`accent6`)        | `#E397A0` | serie secundaria, relleno de bandas |
| Texto / línea "Total"         | `#000000` | ejes, línea de referencia o agregado ("General", "Total AA.PP.") |
| Gris oscuro                   | `#404040` | texto secundario |
| Gris medio                    | `#595959` | series neutras, etiquetas |
| Gris rejilla                  | `#D9D9D9` | líneas de rejilla (discontinuas) |
| Gris panel (`lt2`)            | `#E7E6E6` | series de fondo / poco relevantes |
| Ámbar contraste               | `#FFC000` | **una** serie a resaltar sobre granates |
| Azul contraste               | `#548CC6` | serie ajena al bloque granate (p. ej. "otros países") |

**Secuencia categórica recomendada** (`airef_pal(n)`):
`#83082A`, `#E397A0`, `#8C2633`, `#D46271`, `#430416`, `#595959`, `#D9D9D9`.
- La serie agregada / total va en **negro**, no dentro de la secuencia.
- Para resaltar exactamente una serie: granate `#83082A` (o ámbar `#FFC000`) y el
  resto en grises.
- Escala secuencial (mapas, heatmaps): de `#F4D8DB` a `#430416` pasando por `#83082A`.

## Tipografía

- **Gráficos**: `Gill Sans MT` (stack web: `"Gill Sans MT, Gill Sans, 'Trebuchet MS', 'Segoe UI', sans-serif"`).
- **Tablas / cuadros**: `Century Gothic` (stack web: `"Century Gothic, 'Apple Gothic', 'Trebuchet MS', sans-serif"`).
- Tamaños en gráfico: ejes y leyenda 9–10,5 pt; etiquetas de dato 9 pt; texto normal 10 pt.
- Título del gráfico/cuadro (como texto **fuera** del objeto): 12–14 pt, **negrita**, color `#83082A`.

## Reglas de gráfico

- Fondo blanco. Sin borde en el área de trazado ni en el lienzo.
- **Rejilla**: solo horizontal, `#D9D9D9`, discontinua, 0,75 pt. Sin rejilla vertical.
- Eje: línea negra 0,75 pt, sin marcas de graduación (`tickmarks = none`).
- Líneas: grosor 2,25 pt, **sin marcadores** por defecto; extremos redondeados.
- Barras: sin borde; separación entre grupos ~50 %.
- **Título dentro del objeto desactivado**; el título va como texto encima:
  `GRÁFICO N. TÍTULO EN MAYÚSCULAS (unidad)` — la unidad entre paréntesis
  (`% PIB`, `millones €`, `% var. interanual`, `tasa`, …).
- **Leyenda**: arriba o abajo, horizontal, sin recuadro, texto gris `#595959`.
  Omítela si hay una sola serie.
- **Fuente** debajo, alineada a la izquierda, 8–9 pt, cursiva, gris:
  `Fuente: AIReF` (o `Fuente: IGAE y AIReF`, `Fuente: MTES y AIReF`, …).
- Notas al pie con `*`, `**` en 8 pt.
- Previsiones: tramo con línea discontinua o sombreado `#E397A0` al 40 %; bandas de
  incertidumbre en relleno `#F3D1D5` sin borde.

## Reglas de tabla / cuadro

- Tipografía `Century Gothic`, cuerpo 10 pt.
- Cabecera: fondo granate `#83082A`, texto blanco, negrita. (Alternativa clara:
  fondo `#F4D8DB`, texto `#83082A`.)
- Filas: sin bordes verticales; línea horizontal fina bajo la cabecera y en el total.
- Fila de total/agregado en negrita, fondo `#E7E6E6`.
- Rayado de filas opcional muy sutil (`#F2F2F2`).
- Números alineados a la derecha; texto a la izquierda.
- Título del cuadro: `CUADRO N. TÍTULO EN MAYÚSCULAS (unidad)`, negrita `#83082A`.
- `Fuente:` debajo, igual que en gráficos.

## Formato numérico (locale español)

- Separador de miles: punto. Separador decimal: coma.
- **1 decimal** por defecto (`0,0`). Tasas y % con 1 decimal y símbolo `%` (`0,0%`).
- Importes grandes: `#.##0` sin decimales; en millones si procede.
- Fechas de serie: `ene-25`, `2025T1`, o año `2025` en el eje.
- `-` (guion) para el cero contable / dato no aplicable; `n.d.` para no disponible.
- En R: `format(x, big.mark = ".", decimal.mark = ",", nsmall = 1)` o
  `scales::label_number(big.mark = ".", decimal.mark = ",", accuracy = 0.1)`.

## Helpers disponibles (`assets/airef_theme.R`)

- `airef_colores` — vector con nombres de todos los colores del tema.
- `airef_pal(n)` — devuelve `n` colores de la secuencia categórica.
- `scale_color_airef()`, `scale_fill_airef()` — escalas ggplot2.
- `theme_airef(base_size = 11)` — tema ggplot2 (rejilla horizontal, sin borde, fuente).
- `airef_plotly(p)` — aplica layout AIReF a un objeto plotly.
- `airef_fuente_plotly(p, texto = "Fuente: AIReF")` — anotación de fuente.
- `airef_datatable(df, ...)` — `DT::datatable` con estilo AIReF + CSS Century Gothic.
- `airef_gt(gt_tbl)` — estilo AIReF para tablas `gt`.
- `airef_num(x, dec = 1, pct = FALSE)` — formatea números al estilo español.

Ver ejemplos de uso al final de ese fichero.
