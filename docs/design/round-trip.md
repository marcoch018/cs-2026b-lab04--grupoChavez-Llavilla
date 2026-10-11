# Round-trip: diagrama de diseño vs. diagrama obtenido del código (pyreverse)

| Diferencia observada | Causa | Acción |
|---|---|---|
| No aparece la composición Libro–Ejemplar ni Prestamo–Multa; figuran como atributos (`ejemplares: list[Ejemplar]`, `multa: Multa \| None`). | pyreverse no infiere composición desde colecciones tipadas ni desde atributos opcionales. | Ninguna: limitación de la herramienta. Se mantiene el diagrama de diseño. |
| No hay multiplicidades en ninguna asociación. | El código no expresa multiplicidades. | Agregar validación en `ServicioPrestamos.reservar_libro()` para exigir ejemplar disponible (C3) y documentar la limitación. |
| Las interfaces (VerificadorMatricula, Notificador, RepositorioPrestamos, CatalogoLibros) aparecen como clases, no como interfaces. | Python implementa interfaces con ABC. | Aceptable en Python; se documenta. |
| Los nombres están en snake_case (`buscar_ejemplar_disponible`) frente a camelCase del diagrama. | Convención de Python. | Aceptable; se documenta la equivalencia (C5). |
| Los métodos de los adaptadores aparecen como concretos aunque lanzan NotImplementedError. | pyreverse no analiza el cuerpo de los métodos. | Aceptable; pendiente de integración real. |