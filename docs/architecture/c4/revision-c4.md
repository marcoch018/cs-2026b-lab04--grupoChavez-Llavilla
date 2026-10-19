# Revisión con la lista oficial de c4model.com — BiblioUNSA (E7)

## Aplicación a las 5 vistas
| Grupo | Pregunta | Contexto | Contenedores | Componentes | Dinámica | Despliegue |
|---|---|---|---|---|---|---|
| General | ¿Tiene título? | Sí | Sí | Sí | Sí | Sí |
| General | ¿Se entiende el tipo y el alcance? | Sí (título con tipo de vista y descripción) | Sí | Sí | Sí | Sí |
| General | ¿Tiene leyenda? | Sí | Sí | Sí | Sí | Sí |
| Elementos | ¿Nombre, tipo y descripción? | Sí | Sí | Sí | Sí | Sí |
| Elementos | ¿Tecnología cuando corresponde? | N/A (nivel 1) | Sí | Sí | Sí | Sí (OS y tamaño del VPS) |
| Elementos | ¿Se entienden formas y colores? | Sí (leyenda) | Sí (cilindro BD, tubo cola, navegador PWA) | Sí | Sí | Sí |
| Relaciones | ¿Etiqueta con intención (verbo)? | Sí | Sí | Sí | Sí (pasos numerados) | Sí |
| Relaciones | ¿Protocolo o tecnología? | Sí en sistemas externos | Sí | Sí | Sí | Sí |
| Relaciones | ¿La etiqueta coincide con la dirección? | Sí | Sí | Sí | Sí | Sí |

Evidencia: imágenes en `img/` y `export/*.puml`.

## Hallazgos de la IA (Prompt IA 2) y verificación del equipo
| Vista | Hallazgo de la IA | Verificación del equipo |
|---|---|---|
| Contenedores | La flecha «Encola tareas y lee la caché» mezcla dos intenciones | Correcto: se aceptan ambas porque comparten protocolo (Redis); se documenta en la descripción |
| Contexto | Faltan las tecnologías en las relaciones con las personas | **Falso positivo**: en el nivel 1 no se exigen tecnologías para las personas |
| Despliegue | Nginx aparece sin conexiones | Correcto: se agregaron las relaciones PWA → Nginx y Nginx → API |
| Despliegue | Falta indicar el sistema operativo y el tamaño del VPS | **Falso positivo**: ya figura «Ubuntu Server 24.04, 2 vCPU, 4 GB RAM» en el nodo |
| Componentes | El adaptador académico apunta al sistema externo pero no se ve quién lo llama | Correcto parcial: se invirtió la flecha respecto a paquetes.puml (ver comparacion.md) |
| Todas | Hay leyenda, título y descripción en cada vista | Correcto (cumple) |
