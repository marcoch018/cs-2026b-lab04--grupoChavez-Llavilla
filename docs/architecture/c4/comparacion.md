# Comparaciones — BiblioUNSA (E4 y E6)

## E4. Vista dinámica de C4 frente a la secuencia UML (Lab 05)
La secuencia UML de `secuencia-reservar-libro.puml` muestra detalle de clases y métodos: `ReservaController`, `ServicioPrestamos`, `consultarMatricula(cui)`, el bucle sobre ejemplares, el `alt` por matrícula no vigente y el `opt` del correo. La vista dinámica C4 omite todo eso y muestra solo 9 pasos entre contenedores y componentes (PWA, Reservas, Autenticación, adaptador académico, Catálogo, base de datos y cola) y el sistema externo, sin ramas ni bucles. La secuencia sirve a los developers que implementan el caso de uso; la vista dinámica sirve al equipo técnico y a quien evalúa la arquitectura, porque explica quién habla con quién y en qué orden sin conocer el código.

## E6. Diagrama escrito a mano frente al modelo exportado
| Aspecto | `contexto-manual.puml` (a mano) | Vista exportada de `workspace.dsl` |
|---|---|---|
| Tiempo invertido | Unos 10 min para una sola vista | Unos 40 min el modelo completo, pero produce las 5 vistas |
| Errores encontrados | Hubo que corregir la sintaxis de las macros y repetir los nombres de los elementos y relaciones | `validate` detectó identificadores inexistentes en dos ocasiones (nodos de despliegue sin nombre) |
| Si mañana cambia el nombre de un contenedor | Hay que editarlo a mano en cada archivo .puml que lo mencione | Se cambia una vez en `workspace.dsl` y se vuelve a exportar |

Conclusión: para un diagrama suelto conviene escribir a mano; para varias vistas coherentes conviene el modelo único. Por eso todas las vistas del Lab 06 salen de `workspace.dsl` y `contexto-manual.puml` es solo la comparación.

## Consistencia con el Lab 05 (paquetes.puml)
En `paquetes.puml` los adaptadores dependen del puerto que implementan (por ejemplo, el adaptador académico → Autenticación); en el modelo C4 la flecha va en sentido contrario (Autenticación → adaptador) porque C4 muestra quién llama a quién en ejecución. Es inversión de dependencias: no hay contradicción ni ciclos. Los 9 componentes y las dependencias entre módulos son los mismos de `paquetes.puml`.
