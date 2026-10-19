# Inventario de elementos — BiblioUNSA (E1)

| Elemento | Tipo C4 | Origen |
|---|---|---|
| Estudiante, Bibliotecario | Persona | drivers.md (Lab 04: actores) |
| BiblioUNSA | Sistema de software | Caso 4 de la guía del Lab 04 |
| Sistema Académico UNSA | Sistema externo | drivers.md (RF-05, R-06), ADR-003 |
| Proveedor de identidad institucional | Sistema externo | drivers.md (RF-06, R-05), ADR-002 |
| Servicio de correo | Sistema externo | drivers.md (RF-08), arquitectura.mmd (Lab 04) |
| Aplicación web (PWA) | Contenedor | arquitectura.mmd y secuencia-reservar-libro.puml (participante PWA) |
| API BiblioUNSA (Python / Django) | Contenedor | ADR-001 |
| Worker de tareas (Celery) | Contenedor | ADR-003 y despliegue.py (Lab 04) |
| Base de datos (PostgreSQL) | Contenedor | ADR-001 y despliegue.py |
| Cola y caché (Redis) | Contenedor | ADR-003 y despliegue.py |
| Autenticación, Catálogo, Reservas, Préstamos, Multas, Notificaciones | Componente (de la API) | docs/design/paquetes.puml (Lab 05) |
| Adaptadores Sistema académico, Identidad y Correo | Componente (de la API) | docs/design/paquetes.puml (paquete «Adaptadores externos») |
| Flujo «reservar libro» | Vista dinámica | docs/design/secuencia-reservar-libro.puml (Lab 05) |
| Nginx, VPS, dispositivo del usuario | Nodos de despliegue | despliegue.py (Lab 04), R-03 |

Nivel 4 (código): no se dibuja de nuevo; ver `docs/design/clases.puml`.

## Elementos de despliegue que no son contenedores C4
Nginx es infraestructura (proxy HTTPS) y el VPS es un nodo: aparecen solo en la vista de despliegue, no en la de contenedores. Prometheus y Grafana (de despliegue.py, Lab 04) quedan fuera del modelo del MVP para no modelar más de lo que se construirá en 1 mes.
