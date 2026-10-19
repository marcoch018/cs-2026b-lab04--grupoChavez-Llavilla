# Bitácora de uso de IA — Laboratorio 06 (BiblioUNSA)

| # | Fecha | Herramienta | Prompt (resumen) | Qué propuso la IA | Qué verificamos o corregimos | Decisión |
|---|---|---|---|---|---|---|
| 1 | 17/10 | Claude | Prompt IA 1: borrador de workspace.dsl con inventario.md, ADR-001 y despliegue.py | Modelo con personas, sistema, contenedores, componentes y 5 vistas | Se contrastó con el ADR-001/003 y con paquetes.puml; `structurizr.sh validate` sin errores | Aceptada |
| 2 | 17/10 | Claude | Mismo prompt, revisión del despliegue | Nginx y «Docker Compose» como contenedores de BiblioUNSA | Son infraestructura: pasan a nodos de despliegue; se quitó Docker Compose porque el Lab 04 no lo usa | Corregida |
| 3 | 17/10 | Claude | Pedir tecnologías para PWA y la API | Sugirió React para la PWA | El ADR-001 solo fija Django; se dejó «HTML, JavaScript y Service Worker» sin nombrar un framework | Rechazada |
| 4 | 17/10 | Claude | Definir las flechas entre componentes a partir de paquetes.puml | Copió la dirección adaptador → puerto de Autenticación | C4 muestra llamadas en ejecución: se invirtió a Autenticación → adaptador, sin ciclos (ver comparacion.md) | Corregida |
| 5 | 17/10 | Claude | Prompt IA 2: auditar las 5 vistas con la lista de c4model.com | Cinco hallazgos | Dos falsos positivos (tecnologías en relaciones con personas; SO y tamaño del VPS), uno aceptado (Nginx sin conexiones) | Corregida |
| 6 | 17/10 | Claude | Prompt IA 3: explicar el contexto a un público no técnico en 120 palabras | Texto de 88 palabras | Se verificó que todo lo dicho esté en el modelo (correo institucional, matrícula, avisos, reintentos) | Aceptada |

## Prompts
- **Prompt IA 1:** Actúa como arquitecto de software experto en C4 y Structurizr DSL. Contexto: inventario.md, ADR-001 y despliegue.py. Escribe un workspace con personas, sistema, contenedores con tecnología, componentes de la API, sistemas externos con la etiqueta «Externo» y relaciones con descripción y protocolo; vistas systemContext, container, component, dynamic y deployment. Usa solo las tecnologías del ADR; no confundas contenedor C4 con contenedor Docker.
- **Prompt IA 2:** Actúa como revisor de diagramas. Evalúa estas vistas con la lista de c4model.com (generales, elementos y relaciones) en una tabla; no inventes problemas.
- **Prompt IA 3:** Explica el diagrama de contexto a un público no técnico en máximo 120 palabras, sin jerga.
